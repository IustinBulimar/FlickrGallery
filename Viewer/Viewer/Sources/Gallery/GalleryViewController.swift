import UIKit

class GalleryViewController: UIViewController {
    
    let imageUrl = "https://farm5.staticflickr.com/4577/38490098461_0a7ff927e4.jpg"
    
    @IBAction func didTapViewImageButton(_ sender: Any) {
        let imageViewerViewController = ImageViewerViewController.storyboardInstance(url: imageUrl)
        present(imageViewerViewController, animated: true)
        
    }
    
}

