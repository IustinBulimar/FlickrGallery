import UIKit
import Kingfisher

class ImageViewerViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.kf.setImage(with: URL(string: imageUrl)!) { (image, error, cacheType, url) in
            print(error)
        }
    }
    
    static func storyboardInstance(url: String) -> ImageViewerViewController {
        let vc = storyboardInstance()
        vc.imageUrl = url
        return vc
    }
    
}
