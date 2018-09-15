import UIKit

class ImageViewerViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    static func storyboardInstance(url: String) -> ImageViewerViewController {
        let vc = storyboardInstance()
        vc.imageUrl = url
        return vc
    }
    
}
