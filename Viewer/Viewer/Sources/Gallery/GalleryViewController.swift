import UIKit

class GalleryViewController: UIViewController {
    
    let imageUrl = ""
    
    @IBAction func didTapViewImageButton(_ sender: Any) {
        let imageViewerViewController = ImageViewerViewController.storyboardInstance(url: imageUrl)
        present(imageViewerViewController, animated: true)
        
    }
    
}

