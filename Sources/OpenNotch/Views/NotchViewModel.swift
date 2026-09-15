import SwiftUI
import Combine

@MainActor
public final class NotchViewModel: ObservableObject {
    @Published public var isExpanded: Bool = false
    @Published public var isHovering: Bool = false
    
    private var collapseTask: Task<Void, Never>?
    
    public init() {}
    
    public func onHoverChanged(_ hovering: Bool) {
        isHovering = hovering
        collapseTask?.cancel()
        
        if hovering {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72, blendDuration: 0.05)) {
                self.isExpanded = true
            }
        } else {
            collapseTask = Task {
                try? await Task.sleep(nanoseconds: 280_000_000) // 280ms smooth buffer
                if !Task.isCancelled {
                    await MainActor.run {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.82, blendDuration: 0.05)) {
                            self.isExpanded = false
                        }
                    }
                }
            }
        }
    }
    
    public func toggle() {
        collapseTask?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72, blendDuration: 0.05)) {
            self.isExpanded.toggle()
        }
    }
}
