import SwiftUI

public struct NotchContentView: View {
    @ObservedObject var musicService: MusicService
    @ObservedObject var viewModel: NotchViewModel
    let geometry: NotchGeometry
    
    public init(
        musicService: MusicService,
        viewModel: NotchViewModel,
        geometry: NotchGeometry
    ) {
        self.musicService = musicService
        self.viewModel = viewModel
        self.geometry = geometry
    }
    
    public var body: some View {
        let isExpanded = viewModel.isExpanded
        let track = musicService.currentTrack
        let isPlaying = track.isPlaying
        let brandColor = track.source == .spotify ? Color(red: 0.12, green: 0.84, blue: 0.38) : Color(red: 0.98, green: 0.22, blue: 0.43)
        
        let notchW = geometry.notchWidth
        let notchH = geometry.notchHeight
        let hasNotch = geometry.hasPhysicalNotch
        
        // Bold extended notch bar (e.g. 380 pt wide when collapsed, giving that iconic big notch look)
        let earWidth: CGFloat = 80
        let collapsedWidth: CGFloat = hasNotch ? (notchW + (earWidth * 2)) : 220
        let collapsedHeight: CGFloat = notchH
        
        let expandedWidth: CGFloat = 540
        let expandedHeight: CGFloat = hasNotch ? (notchH + 146) : 156
        
        let targetWidth: CGFloat = isExpanded ? expandedWidth : collapsedWidth
        let targetHeight: CGFloat = isExpanded ? expandedHeight : collapsedHeight
        let cornerRadius: CGFloat = isExpanded ? 24 : 14
        let earRadius: CGFloat = isExpanded ? 10 : 7
        
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                // Background Notch Bezel (Pure pitch black #000000 matching Apple hardware notch)
                NotchBezelShape(cornerRadius: cornerRadius, earRadius: earRadius)
                    .fill(Color.black)
                    .overlay(
                        NotchBezelShape(cornerRadius: cornerRadius, earRadius: earRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.06),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.8
                            )
                    )
                
                // Content Layer
                if isExpanded {
                    VStack(spacing: 0) {
                        if hasNotch {
                            // Top Notch Level: Wings flanking the physical non-pixel camera zone
                            HStack(spacing: 0) {
                                // Left Wing: Brand badge
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(brandColor)
                                        .frame(width: 6, height: 6)
                                        .shadow(color: brandColor.opacity(0.6), radius: 3, x: 0, y: 0)
                                    
                                    Text(track.source == .none ? "OPENNOTCH" : track.source.rawValue.uppercased())
                                        .font(.system(size: 9.5, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                        .tracking(0.5)
                                }
                                .padding(.leading, 18)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Center Gap: The physical camera cutout (NO PIXELS)
                                Color.clear
                                    .frame(width: notchW, height: notchH)
                                
                                // Right Wing: Live animated equalizer
                                HStack(spacing: 6) {
                                    EqualizerView(
                                        isPlaying: track.isPlaying,
                                        color: brandColor,
                                        barCount: 4,
                                        barWidth: 2.5,
                                        maxHeight: 12
                                    )
                                }
                                .padding(.trailing, 18)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .frame(height: notchH)
                        }
                        
                        // Main Interactive Card: 100% visible BELOW the physical notch!
                        MusicView(musicService: musicService)
                            .padding(.top, hasNotch ? 2 : 12)
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.97)),
                        removal: .opacity
                    ))
                } else {
                    // Big Collapsed Notch Bar
                    if hasNotch {
                        HStack(spacing: 0) {
                            // Left Wing (Left of hardware notch)
                            HStack(spacing: 6) {
                                if isPlaying {
                                    if let artwork = track.artwork {
                                        Image(nsImage: artwork)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 20, height: 20)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 0.5))
                                    } else {
                                        Circle()
                                            .fill(LinearGradient(colors: [brandColor, brandColor.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 20, height: 20)
                                            .overlay {
                                                Image(systemName: "music.note")
                                                    .font(.system(size: 9, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                    }
                                    
                                    Text(track.title)
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.95))
                                        .lineLimit(1)
                                } else {
                                    Image(systemName: "music.note")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.45))
                                    
                                    Text("OpenNotch")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .padding(.leading, 12)
                            .frame(width: earWidth, height: notchH, alignment: .leading)
                            
                            // Center Hardware Gap (The Physical Camera Notch)
                            Color.clear
                                .frame(width: notchW, height: notchH)
                            
                            // Right Wing (Right of hardware notch)
                            HStack(spacing: 6) {
                                if isPlaying {
                                    Text(formatRemaining(track))
                                        .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.65))
                                    
                                    EqualizerView(
                                        isPlaying: true,
                                        color: brandColor,
                                        barCount: 3,
                                        barWidth: 2,
                                        maxHeight: 11
                                    )
                                } else {
                                    Image(systemName: "waveform")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.45))
                                }
                            }
                            .padding(.trailing, 12)
                            .frame(width: earWidth, height: notchH, alignment: .trailing)
                        }
                        .frame(width: collapsedWidth, height: collapsedHeight)
                        .transition(.opacity)
                    } else {
                        // Non-notched display (External monitor)
                        HStack(spacing: 8) {
                            if isPlaying {
                                if let artwork = track.artwork {
                                    Image(nsImage: artwork)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 20, height: 20)
                                        .clipShape(Circle())
                                }
                                Text(track.title)
                                    .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.95))
                                    .lineLimit(1)
                                Spacer()
                                EqualizerView(isPlaying: true, color: brandColor, barCount: 3, barWidth: 2, maxHeight: 11)
                            } else {
                                Spacer()
                                Text("OpenNotch")
                                    .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 14)
                        .frame(width: collapsedWidth, height: collapsedHeight)
                        .transition(.opacity)
                    }
                }
            }
            .frame(width: targetWidth, height: targetHeight)
            .animation(
                isExpanded
                    ? .spring(response: 0.35, dampingFraction: 0.72, blendDuration: 0.05)
                    : .spring(response: 0.28, dampingFraction: 0.82, blendDuration: 0.05),
                value: isExpanded
            )
            .animation(
                .spring(response: 0.35, dampingFraction: 0.75),
                value: isPlaying
            )
            
            Spacer(minLength: 0)
        }
        .frame(width: 570, height: 200, alignment: .top)
        .contentShape(Rectangle())
        .onHover { hovering in
            viewModel.onHoverChanged(hovering)
        }
    }
    
    private func formatRemaining(_ track: TrackInfo) -> String {
        guard track.duration > 0 else { return "" }
        let rem = max(track.duration - track.playerPosition, 0)
        let mins = Int(rem) / 60
        let secs = Int(rem) % 60
        return String(format: "-%d:%02d", mins, secs)
    }
}
