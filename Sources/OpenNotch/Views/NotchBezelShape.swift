import SwiftUI

public struct NotchBezelShape: Shape {
    public var cornerRadius: CGFloat
    public var earRadius: CGFloat
    
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(cornerRadius, earRadius) }
        set {
            cornerRadius = newValue.first
            earRadius = newValue.second
        }
    }
    
    public init(cornerRadius: CGFloat = 14, earRadius: CGFloat = 8) {
        self.cornerRadius = cornerRadius
        self.earRadius = earRadius
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        let cr = min(cornerRadius, min(w / 2, h / 2))
        let er = min(earRadius, 14.0)
        
        // Start at top-left ear flare
        path.move(to: CGPoint(x: rect.minX - er, y: rect.minY))
        
        // Top edge including both ears
        path.addLine(to: CGPoint(x: rect.maxX + er, y: rect.minY))
        
        // Top-right concave ear curve (flares into the bezel)
        if er > 0 {
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY + er),
                control: CGPoint(x: rect.maxX + (er * 0.2), y: rect.minY + (er * 0.2))
            )
        }
        
        // Right vertical edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cr))
        
        // Bottom-right convex rounded corner
        path.addArc(
            center: CGPoint(x: rect.maxX - cr, y: rect.maxY - cr),
            radius: cr,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        // Bottom horizontal edge
        path.addLine(to: CGPoint(x: rect.minX + cr, y: rect.maxY))
        
        // Bottom-left convex rounded corner
        path.addArc(
            center: CGPoint(x: rect.minX + cr, y: rect.maxY - cr),
            radius: cr,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        // Left vertical edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + er))
        
        // Top-left concave ear curve (flares into the bezel)
        if er > 0 {
            path.addQuadCurve(
                to: CGPoint(x: rect.minX - er, y: rect.minY),
                control: CGPoint(x: rect.minX - (er * 0.2), y: rect.minY + (er * 0.2))
            )
        }
        
        path.closeSubpath()
        return path
    }
}
