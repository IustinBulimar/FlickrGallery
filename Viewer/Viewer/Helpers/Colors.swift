import UIKit

extension UIColor {
    
    static func customColor(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: alpha)
    }
    
    static var primaryColor: UIColor { return .customColor(red: 255, green: 126, blue: 121) }
}
