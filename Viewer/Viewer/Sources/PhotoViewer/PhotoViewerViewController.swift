import UIKit
import Kingfisher

class PhotoViewerViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var photoUrl = ""
    var photoId = ""
    var isFavorite = false
    
    static func storyboardInstance(url: String, id: String) -> PhotoViewerViewController {
        let vc = storyboardInstance()
        vc.photoUrl = url
        vc.photoId = id
        
        RemoteData.isFavorite(photoId: id)
            .done { isFavorite in
                vc.isFavorite = isFavorite
                vc.favoriteButton.setImage((isFavorite ? #imageLiteral(resourceName: "favorite-full") : #imageLiteral(resourceName: "favorite-empty")).withRenderingMode(.alwaysTemplate), for: .normal)
            }.catch { error in
                print(error)
        }
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        photoImageView.kf.setImage(with: URL(string: photoUrl)!) { (image, error, cacheType, url) in
            if let error = error {
                print(error)
            }
        }
    }
    
    @IBAction func didTapImageView(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapFavoriteButton(_ sender: Any) {
        if isFavorite {
            RemoteData.removeFromFavorites(photoId: photoId)
                .done {
                    self.favoriteButton.setImage(#imageLiteral(resourceName: "favorite-empty").withRenderingMode(.alwaysTemplate), for: .normal)
                }.catch { error in
                    print(error)
            }
        } else {
            RemoteData.addToFavorites(photoId: photoId)
                .done {
                    self.favoriteButton.setImage(#imageLiteral(resourceName: "favorite-full").withRenderingMode(.alwaysTemplate), for: .normal)
                }.catch { error in
                    print(error)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setZoomScale()
    }
    
    private func setZoomScale() {
        let minZoomScale = min(scrollView.bounds.size.width / photoImageView.image!.size.width,
                               scrollView.bounds.size.height / photoImageView.image!.size.height)
        scrollView.minimumZoomScale = minZoomScale
        scrollView.zoomScale = minZoomScale
        updateConstraints(size: view.bounds.size)
    }
    
}

extension PhotoViewerViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints(size: view.bounds.size)
    }
    
    fileprivate func updateConstraints(size: CGSize) {
        if let image = photoImageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let viewWidth = scrollView.bounds.size.width
            let viewHeight = scrollView.bounds.size.height
            
            // center image if it is smaller than the scroll view
            var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
            if hPadding < 0 { hPadding = 0 }
            
            var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
            if vPadding < 0 { vPadding = 0 }
            
            imageViewLeadingConstraint.constant = hPadding
            imageViewTrailingConstraint.constant = hPadding
            
            imageViewTopConstraint.constant = vPadding
            imageViewBottomConstraint.constant = vPadding
            
            view.layoutIfNeeded()
        }
    }
    
}
