import UIKit

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var photos: [Photo] = []
    
    var animationAreaFrame: CGRect?
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.register(cellClass: PhotoCell.self)
        tableView.rowHeight = 300
        tableView.dataSource = self
        tableView.delegate = self
        
        RemoteData.getRecentPhotos()
            .done { photosResponse in
                self.photos = photosResponse.info.photos
                self.tableView.reloadData()
            }.catch { error in
                print(error)
        }
    }
    
}

extension GalleryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photo = photos[indexPath.row]
        let cell = tableView.dequeueReusableCell(ofType: PhotoCell.self, for: indexPath)
        cell.titleLabel.text = photo.title
        cell.photoImageView.kf.setImage(with: URL(string: photo.url)!) { (image, error, cacheType, url) in
            if let error = error {
                print(error)
            }
        }
        return cell
    }
    
}

extension GalleryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let photoViewerViewController = PhotoViewerViewController.storyboardInstance(url: photo.url)
        photoViewerViewController.transitioningDelegate = self
        selectedIndexPath = indexPath
        present(photoViewerViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

extension GalleryViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let selectedIndexPath = selectedIndexPath,
            let cell = tableView.cellForRow(at: selectedIndexPath) as? PhotoCell,
            let selectedImageView = cell.photoImageView,
            let photoViewerViewController = presented as? PhotoViewerViewController,
            let destinationImageView = photoViewerViewController.photoImageView else {
                return nil
        }
        
        animationAreaFrame = view.convert(tableView.frame, to: nil)
        let fromImageViewRelativeFrame = selectedImageView.convert(selectedImageView.frame, to: nil)
        
        let toImageViewRelativeFrame = photoViewerViewController.view.frame.insetBy(dx: 0, dy: UIApplication.shared.statusBarFrame.height).offsetBy(dx: 0, dy: UIApplication.shared.statusBarFrame.height / 2)
        
        return ImagePreviewAnimator(fromImageView: selectedImageView,
                                    toImageView: destinationImageView,
                                    animationAreaFrame: animationAreaFrame!,
                                    fromImageViewRelativeFrame: fromImageViewRelativeFrame,
                                    toImageViewRelativeFrame: toImageViewRelativeFrame)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let selectedIndexPath = selectedIndexPath,
            let cell = tableView.cellForRow(at: selectedIndexPath) as? PhotoCell,
            let selectedImageView = cell.photoImageView,
            let photoViewerViewController = dismissed as? PhotoViewerViewController,
            let sourceImageView = photoViewerViewController.photoImageView else {
                return nil
        }
        
        let fromImageViewRelativeFrame = sourceImageView.superview!.convert(sourceImageView.frame, to: nil)
        let toImageViewRelativeFrame = selectedImageView.superview!.convert(selectedImageView.frame, to: self.view)
        
        self.selectedIndexPath = nil
        
        return ImagePreviewAnimator(fromImageView: sourceImageView,
                                    toImageView: selectedImageView,
                                    animationAreaFrame: animationAreaFrame!,
                                    fromImageViewRelativeFrame: fromImageViewRelativeFrame,
                                    toImageViewRelativeFrame: toImageViewRelativeFrame)
    }
    
}

