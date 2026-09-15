import SwiftUI

public struct MusicView: View {
    @ObservedObject var musicService: MusicService
    
    public init(musicService: MusicService) {
        self.musicService = musicService
    }
    
    public init() {
        self.init(musicService: MusicService.shared)
    }
    
    public var body: some View {
        let track = musicService.currentTrack
        let progress = track.duration > 0 ? min(max(track.playerPosition / track.duration, 0.0), 1.0) : 0.0
        let brandColor = track.source == .spotify ? Color(red: 0.12, green: 0.84, blue: 0.38) : Color(red: 0.98, green: 0.22, blue: 0.43)
        
        HStack(spacing: 16) {
            // MARK: - Left: Album Artwork with Ambient Aura
            ZStack {
                // Ambient colorful glow behind artwork
                if let artwork = track.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .blur(radius: 18)
                        .opacity(0.6)
                        .scaleEffect(1.1)
                    
                    // Main crisp artwork
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 76, height: 76)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.45), radius: 10, x: 0, y: 5)
                } else {
                    // Fallback artwork with modern vibrant gradient
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.98, green: 0.22, blue: 0.43),
                                    Color(red: 0.65, green: 0.15, blue: 0.85),
                                    Color(red: 0.25, green: 0.30, blue: 0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 76, height: 76)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .overlay {
                            Image(systemName: "music.quarternote.3")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                }
            }
            .frame(width: 76, height: 76)
            
            // MARK: - Center: Track Info, Progress & Controls
            VStack(alignment: .leading, spacing: 6) {
                // Header: Source badge chip & animated equalizer
                HStack(alignment: .center, spacing: 6) {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(brandColor)
                            .frame(width: 6, height: 6)
                            .shadow(color: brandColor.opacity(0.6), radius: 3, x: 0, y: 0)
                        
                        Text(track.source == .none ? "OPENNOTCH" : track.source.rawValue.uppercased())
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.75))
                            .tracking(0.6)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(Color.white.opacity(0.08))
                    )
                    
                    Spacer()
                    
                    EqualizerView(
                        isPlaying: track.isPlaying,
                        color: brandColor,
                        barCount: 4,
                        barWidth: 2.5,
                        maxHeight: 12
                    )
                }
                
                // Track Title
                Text(track.title)
                    .font(.system(size: 14.5, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Artist & Album
                Text(track.artist + (track.album.isEmpty ? "" : " — \(track.album)"))
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(.white.opacity(0.65))
                    .lineLimit(1)
                
                // Progress Bar with scrubber
                VStack(spacing: 3) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            // Track background
                            Capsule()
                                .fill(Color.white.opacity(0.14))
                                .frame(height: 3.5)
                            
                            // Fill bar
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [brandColor, brandColor.opacity(0.85)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(geo.size.width * CGFloat(progress), 4), height: 3.5)
                        }
                        .contentShape(Rectangle())
                    }
                    .frame(height: 3.5)
                    
                    HStack {
                        Text(formatSeconds(track.playerPosition))
                            .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Spacer()
                        
                        Text(track.duration > 0 ? "-\(formatSeconds(max(track.duration - track.playerPosition, 0)))" : "--:--")
                            .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.top, 1)
                
                // Media Controls Row
                HStack(spacing: 14) {
                    // Previous
                    Button(action: { musicService.previousTrack() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.white.opacity(0.08)))
                            .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                    }
                    .buttonStyle(PlainHoverButtonStyle())
                    
                    // Play/Pause (Iconic glowing white circle)
                    Button(action: { musicService.togglePlayPause() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 34, height: 34)
                                .shadow(color: Color.white.opacity(0.25), radius: 8, x: 0, y: 1)
                            
                            Image(systemName: track.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(.black)
                                .offset(x: track.isPlaying ? 0 : 1)
                        }
                    }
                    .buttonStyle(PlainHoverButtonStyle(pressedScale: 0.90))
                    
                    // Next
                    Button(action: { musicService.nextTrack() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.white.opacity(0.08)))
                            .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                    }
                    .buttonStyle(PlainHoverButtonStyle())
                    
                    Spacer()
                }
                .padding(.top, 2)
            }
            
            // MARK: - Right: Vertical Divider & Volume Deck
            HStack(spacing: 14) {
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 80)
                
                // Volume slider
                VStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.55))
                    
                    // Vertical or compact horizontal volume
                    GeometryReader { vGeo in
                        ZStack(alignment: .bottom) {
                            Capsule()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 5)
                            
                            Capsule()
                                .fill(Color.white.opacity(0.85))
                                .frame(width: 5, height: max(vGeo.size.height * CGFloat(musicService.volume), 4))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: 16, height: 46)
                    
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(width: 24)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
    
    private func formatSeconds(_ seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite && seconds >= 0 else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// Interactive scale button style with zero lag
struct PlainHoverButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.92
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
