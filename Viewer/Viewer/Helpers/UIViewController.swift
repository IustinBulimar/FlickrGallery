import UIKit

extension UIViewController {
    
    class func storyboardInstance() -> Self {
        return genericStoryboardInstance()
    }
    
    private class func genericStoryboardInstance<T>() -> T {
        let storyboard = UIStoryboard(name: "\(T.self)", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! T
        return viewController
    }
    
}
