import AppKit

public struct NotchGeometry: Equatable {
    public let hasPhysicalNotch: Bool
    public let notchWidth: CGFloat
    public let notchHeight: CGFloat
    public let screenFrame: NSRect
    public let topCenter: CGPoint
    
    public init(
        hasPhysicalNotch: Bool,
        notchWidth: CGFloat,
        notchHeight: CGFloat,
        screenFrame: NSRect,
        topCenter: CGPoint
    ) {
        self.hasPhysicalNotch = hasPhysicalNotch
        self.notchWidth = notchWidth
        self.notchHeight = notchHeight
        self.screenFrame = screenFrame
        self.topCenter = topCenter
    }
}

public enum NotchDetector {
    public static func currentGeometry(for screen: NSScreen? = NSScreen.main) -> NotchGeometry {
        guard let screen = screen else {
            let defaultFrame = NSRect(x: 0, y: 0, width: 1440, height: 900)
            return NotchGeometry(
                hasPhysicalNotch: false,
                notchWidth: 170,
                notchHeight: 32,
                screenFrame: defaultFrame,
                topCenter: CGPoint(x: defaultFrame.midX, y: defaultFrame.maxY)
            )
        }
        
        let screenFrame = screen.frame
        let topLeft = screen.auxiliaryTopLeftArea
        let topRight = screen.auxiliaryTopRightArea
        
        if let topLeft = topLeft, let topRight = topRight,
           topRight.minX > topLeft.maxX, topLeft.height > 0 {
            let width = topRight.minX - topLeft.maxX
            let height = topLeft.height
            let centerX = topLeft.maxX + (width / 2.0)
            return NotchGeometry(
                hasPhysicalNotch: true,
                notchWidth: width,
                notchHeight: height,
                screenFrame: screenFrame,
                topCenter: CGPoint(x: centerX, y: screenFrame.maxY)
            )
        }
        
        // Fallback for displays without a notch (external monitors or notchless Macs)
        return NotchGeometry(
            hasPhysicalNotch: false,
            notchWidth: 160,
            notchHeight: 32,
            screenFrame: screenFrame,
            topCenter: CGPoint(x: screenFrame.midX, y: screenFrame.maxY)
        )
    }
}
