import AppKit
import SwiftUI

public final class NotchPanel: NSPanel {
    public init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        self.isMovableByWindowBackground = false
        self.ignoresMouseEvents = false
        self.acceptsMouseMovedEvents = true
    }
    
    public override var canBecomeKey: Bool { false }
    public override var canBecomeMain: Bool { false }
}

public final class NotchHostingView<Content: View>: NSHostingView<Content> {
    public var hitTestBoundsProvider: ((NSPoint) -> Bool)?
    
    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    public override func hitTest(_ point: NSPoint) -> NSView? {
        if let provider = hitTestBoundsProvider {
            if provider(point) {
                return super.hitTest(point)
            } else {
                return nil
            }
        }
        return super.hitTest(point)
    }
}

@MainActor
public final class NotchWindowController: ObservableObject {
    public static let shared = NotchWindowController()
    
    public let viewModel = NotchViewModel()
    private var panel: NotchPanel?
    private var geometry: NotchGeometry = NotchDetector.currentGeometry()
    
    private let windowWidth: CGFloat = 570
    private let windowHeight: CGFloat = 200
    
    public init() {}
    
    public func setup() {
        self.geometry = NotchDetector.currentGeometry()
        
        let frame = NSRect(
            x: geometry.topCenter.x - (windowWidth / 2.0),
            y: geometry.screenFrame.maxY - windowHeight,
            width: windowWidth,
            height: windowHeight
        )
        
        let panel = NotchPanel(contentRect: frame)
        
        let contentView = NotchContentView(
            musicService: MusicService.shared,
            viewModel: viewModel,
            geometry: geometry
        )
        
        let hostingView = NotchHostingView(rootView: contentView)
        hostingView.hitTestBoundsProvider = { [weak self] point in
            guard let self = self else { return true }
            let isExp = self.viewModel.isExpanded
            let hasNotch = self.geometry.hasPhysicalNotch
            let notchW = self.geometry.notchWidth
            let notchH = self.geometry.notchHeight
            
            let activeWidth: CGFloat
            let activeHeight: CGFloat
            
            if isExp {
                activeWidth = 556
                activeHeight = hasNotch ? (notchH + 152) : 162
            } else {
                // Collapsed big notch bar bounds
                activeWidth = hasNotch ? (notchW + 168) : 228
                activeHeight = notchH + 4
            }
            
            let x = (self.windowWidth - activeWidth) / 2.0
            let y = self.windowHeight - activeHeight
            let rect = NSRect(x: x, y: y, width: activeWidth, height: activeHeight)
            return rect.contains(point)
        }
        
        panel.contentView = hostingView
        panel.orderFrontRegardless()
        self.panel = panel
    }
    
    public func toggleExpanded() {
        viewModel.toggle()
    }
    
    public func updateGeometry() {
        self.geometry = NotchDetector.currentGeometry()
        let frame = NSRect(
            x: geometry.topCenter.x - (windowWidth / 2.0),
            y: geometry.screenFrame.maxY - windowHeight,
            width: windowWidth,
            height: windowHeight
        )
        panel?.setFrame(frame, display: true)
    }
}
