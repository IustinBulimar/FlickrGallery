import UIKit
import PBImageView

let animationDuration = 0.2

class ImagePreviewAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var fromImageView: UIImageView
    var toImageView: UIImageView
    
    var transitionImageViewStartFrame: CGRect
    var transitionImageViewEndFrame: CGRect
    
    var animationArea: UIView
    var transitionImageView: PBImageView?
    
    init(fromImageView: UIImageView, toImageView: UIImageView, animationAreaFrame: CGRect, fromImageViewRelativeFrame transitionImageViewStartFrame: CGRect, toImageViewRelativeFrame transitionImageViewEndFrame: CGRect) {
        
        self.fromImageView = fromImageView
        self.toImageView = toImageView
        
        self.animationArea = UIView(frame: animationAreaFrame)
        self.animationArea.clipsToBounds = true
        
        self.transitionImageViewStartFrame = transitionImageViewStartFrame
        self.transitionImageViewEndFrame = transitionImageViewEndFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        prepareAnimation(using: transitionContext)
        
        fromImageView.isHidden = true
        toImageView.isHidden = true
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        fromView?.alpha = 0.5
                        toView?.alpha = 1
                        self.transitionImageView?.frame = self.transitionImageViewEndFrame
                        self.transitionImageView?.contentMode = self.toImageView.contentMode
        },
                       completion: { completed in
                        if completed  {
                            self.animationArea.removeFromSuperview()
                            
                            self.fromImageView.isHidden = false
                            self.toImageView.isHidden = false
                            
                            transitionContext.completeTransition(true)
                        } else {
                            transitionContext.completeTransition(false)
                        }
        })
    }
    
    func prepareAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)
        
        toView?.alpha = 0
        containerView.addSubview(toView!)
        containerView.addSubview(animationArea)
        transitionImageViewStartFrame = animationArea.convert(transitionImageViewStartFrame, from: containerView)
        transitionImageViewEndFrame = animationArea.convert(transitionImageViewEndFrame, from: containerView)
        
        transitionImageView = PBImageView(image: fromImageView.image)
        transitionImageView?.frame = transitionImageViewStartFrame
        transitionImageView?.contentMode = fromImageView.contentMode
        transitionImageView?.clipsToBounds = true
        
        animationArea.addSubview(transitionImageView!)
    }
    
}

