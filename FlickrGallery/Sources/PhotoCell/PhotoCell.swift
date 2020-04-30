import UIKit

class PhotoCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func startLoading() {
        blurView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
        blurView.isHidden = true
    }
    
}
