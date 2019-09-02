
import CoreGraphics

extension CGSize {
    
    var identifiableDescription: String {
        return "{\(width),\(height)}"
    }
    
    var magnitude: CGFloat {
        return width * height
    }
    
    init(square: CGFloat) {
        self.init(width: square, height: square)
    }

}
