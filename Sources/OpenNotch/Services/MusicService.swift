import Foundation
import AppKit
import Combine

public struct TrackInfo: Equatable {
    public var title: String
    public var artist: String
    public var album: String
    public var isPlaying: Bool
    public var playerPosition: Double
    public var duration: Double
    public var source: MusicSource
    public var artwork: NSImage?
    
    public init(
        title: String = "No Track Playing",
        artist: String = "OpenNotch Music",
        album: String = "",
        isPlaying: Bool = false,
        playerPosition: Double = 0,
        duration: Double = 0,
        source: MusicSource = .none,
        artwork: NSImage? = nil
    ) {
        self.title = title
        self.artist = artist
        self.album = album
        self.isPlaying = isPlaying
        self.playerPosition = playerPosition
        self.duration = duration
        self.source = source
        self.artwork = artwork
    }
}

public enum MusicSource: String {
    case music = "Apple Music"
    case spotify = "Spotify"
    case none = "None"
}

@MainActor
public final class MusicService: ObservableObject {
    public static let shared = MusicService()
    
    @Published public private(set) var currentTrack: TrackInfo = TrackInfo()
    @Published public private(set) var isAvailable: Bool = false
    @Published public var volume: Double = 0.75
    
    private var timer: Timer?
    private var lastArtworkTrackId: String = ""
    private var cachedArtwork: NSImage?
    
    public init() {
        startPolling()
        updateNowPlaying()
    }
    
    public func startPolling() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateNowPlaying()
            }
        }
    }
    
    public func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    public func updateNowPlaying() {
        // Check Spotify first, then Apple Music
        if isAppRunning("com.spotify.client") {
            if updateFromSpotify() {
                isAvailable = true
                return
            }
        }
        
        if isAppRunning("com.apple.Music") {
            if updateFromAppleMusic() {
                isAvailable = true
                return
            }
        }
        
        // Neither playing or running
        if currentTrack.isPlaying {
            currentTrack.isPlaying = false
        }
    }
    
    private func isAppRunning(_ bundleId: String) -> Bool {
        !NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).isEmpty
    }
    
    // MARK: - Spotify AppleScript
    private func updateFromSpotify() -> Bool {
        let scriptSource = """
        if application "Spotify" is running then
            tell application "Spotify"
                set pState to player state as string
                set tName to name of current track
                set tArtist to artist of current track
                set tAlbum to album of current track
                set tPos to player position
                set tDur to (duration of current track) / 1000
                set tArt to artwork url of current track
                return pState & "|||" & tName & "|||" & tArtist & "|||" & tAlbum & "|||" & tPos & "|||" & tDur & "|||" & tArt
            end tell
        else
            return "stopped"
        end if
        """
        
        guard let script = NSAppleScript(source: scriptSource) else { return false }
        var errorInfo: NSDictionary?
        let result = script.executeAndReturnError(&errorInfo)
        
        if let stringValue = result.stringValue, !stringValue.isEmpty && stringValue != "stopped" {
            let parts = stringValue.components(separatedBy: "|||")
            if parts.count >= 6 {
                let isPlaying = parts[0].lowercased() == "playing"
                let title = parts[1]
                let artist = parts[2]
                let album = parts[3]
                let position = Double(parts[4]) ?? 0
                let duration = Double(parts[5]) ?? 0
                let artworkUrl = parts.count > 6 ? parts[6] : ""
                
                let trackId = "\(title)-\(artist)"
                if trackId != lastArtworkTrackId {
                    lastArtworkTrackId = trackId
                    cachedArtwork = nil
                    if !artworkUrl.isEmpty, let url = URL(string: artworkUrl) {
                        fetchRemoteArtwork(url: url)
                    }
                }
                
                self.currentTrack = TrackInfo(
                    title: title,
                    artist: artist,
                    album: album,
                    isPlaying: isPlaying,
                    playerPosition: position,
                    duration: duration,
                    source: .spotify,
                    artwork: cachedArtwork
                )
                return true
            }
        }
        return false
    }
    
    // MARK: - Apple Music AppleScript
    private func updateFromAppleMusic() -> Bool {
        let scriptSource = """
        if application "Music" is running then
            tell application "Music"
                set pState to player state as string
                if pState is not "stopped" then
                    set tName to name of current track
                    set tArtist to artist of current track
                    set tAlbum to album of current track
                    set tPos to player position
                    set tDur to duration of current track
                    return pState & "|||" & tName & "|||" & tArtist & "|||" & tAlbum & "|||" & tPos & "|||" & tDur
                else
                    return "stopped"
                end if
            end tell
        else
            return "stopped"
        end if
        """
        
        guard let script = NSAppleScript(source: scriptSource) else { return false }
        var errorInfo: NSDictionary?
        let result = script.executeAndReturnError(&errorInfo)
        
        if let stringValue = result.stringValue, !stringValue.isEmpty && stringValue != "stopped" {
            let parts = stringValue.components(separatedBy: "|||")
            if parts.count >= 6 {
                let isPlaying = parts[0].lowercased() == "playing"
                let title = parts[1]
                let artist = parts[2]
                let album = parts[3]
                let position = Double(parts[4]) ?? 0
                let duration = Double(parts[5]) ?? 0
                
                let trackId = "\(title)-\(artist)"
                if trackId != lastArtworkTrackId {
                    lastArtworkTrackId = trackId
                    cachedArtwork = fetchAppleMusicArtwork()
                }
                
                self.currentTrack = TrackInfo(
                    title: title,
                    artist: artist,
                    album: album,
                    isPlaying: isPlaying,
                    playerPosition: position,
                    duration: duration,
                    source: .music,
                    artwork: cachedArtwork
                )
                return true
            }
        }
        return false
    }
    
    private func fetchAppleMusicArtwork() -> NSImage? {
        let artworkScript = """
        tell application "Music"
            try
                if (count of artworks of current track) > 0 then
                    return data of raw data of artwork 1 of current track
                end if
            end try
            return ""
        end tell
        """
        guard let script = NSAppleScript(source: artworkScript) else { return nil }
        var errorInfo: NSDictionary?
        let result = script.executeAndReturnError(&errorInfo)
        let data = result.data
        if !data.isEmpty {
            return NSImage(data: data)
        }
        return nil
    }
    
    private func fetchRemoteArtwork(url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = NSImage(data: data) {
                    await MainActor.run {
                        self.cachedArtwork = image
                        self.currentTrack.artwork = image
                    }
                }
            } catch {
                // Ignore network error for artwork
            }
        }
    }
    
    // MARK: - Playback Controls
    public func togglePlayPause() {
        let appName = currentTrack.source == .spotify ? "Spotify" : "Music"
        runScript("tell application \"\(appName)\" to playpause")
        updateNowPlaying()
    }
    
    public func nextTrack() {
        let appName = currentTrack.source == .spotify ? "Spotify" : "Music"
        runScript("tell application \"\(appName)\" to next track")
        updateNowPlaying()
    }
    
    public func previousTrack() {
        let appName = currentTrack.source == .spotify ? "Spotify" : "Music"
        runScript("tell application \"\(appName)\" to previous track")
        updateNowPlaying()
    }
    
    public func seek(to progress: Double) {
        guard currentTrack.duration > 0 else { return }
        let clamped = min(max(progress, 0.0), 1.0)
        let newPos = clamped * currentTrack.duration
        let appName = currentTrack.source == .spotify ? "Spotify" : "Music"
        runScript("tell application \"\(appName)\" to set player position to \(newPos)")
        currentTrack.playerPosition = newPos
    }
    
    public func setVolume(_ newVolume: Double) {
        let clamped = min(max(newVolume, 0.0), 1.0)
        let intVol = Int(clamped * 100)
        let appName = currentTrack.source == .spotify ? "Spotify" : "Music"
        runScript("tell application \"\(appName)\" to set sound volume to \(intVol)")
        self.volume = clamped
    }
    
    @discardableResult
    private func runScript(_ source: String) -> String? {
        var errorInfo: NSDictionary?
        return NSAppleScript(source: source)?.executeAndReturnError(&errorInfo).stringValue
    }
}
