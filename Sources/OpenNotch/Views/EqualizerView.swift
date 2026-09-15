import SwiftUI

public struct EqualizerView: View {
    let isPlaying: Bool
    let color: Color
    let barCount: Int
    let barWidth: CGFloat
    let maxHeight: CGFloat
    
    public init(
        isPlaying: Bool,
        color: Color = Color.green,
        barCount: Int = 4,
        barWidth: CGFloat = 2.5,
        maxHeight: CGFloat = 14
    ) {
        self.isPlaying = isPlaying
        self.color = color
        self.barCount = barCount
        self.barWidth = barWidth
        self.maxHeight = maxHeight
    }
    
    public var body: some View {
        if isPlaying {
            TimelineView(.animation(minimumInterval: 0.12)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(0..<barCount, id: \.self) { i in
                        let phase = Double(i) * 1.3
                        let sinVal = abs(sin(time * 5.0 + phase))
                        let height = max(3.0, sinVal * maxHeight)
                        Capsule()
                            .fill(color)
                            .frame(width: barWidth, height: height)
                            .animation(.easeOut(duration: 0.12), value: height)
                    }
                }
            }
        } else {
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<barCount, id: \.self) { _ in
                    Capsule()
                        .fill(color.opacity(0.4))
                        .frame(width: barWidth, height: 3)
                }
            }
        }
    }
}
