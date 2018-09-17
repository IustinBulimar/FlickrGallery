import UIKit
import Kingfisher

class PhotoViewerViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var imageUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoImageView.kf.setImage(with: URL(string: imageUrl)!) { (image, error, cacheType, url) in
            if let error = error {
                print(error)
            }
        }
    }
    
    @IBAction func didTapImageView(_ sender: Any) {
        dismiss(animated: true)
    }
    
    static func storyboardInstance(url: String) -> PhotoViewerViewController {
        let vc = storyboardInstance()
        vc.imageUrl = url
        return vc
    }
    
}
