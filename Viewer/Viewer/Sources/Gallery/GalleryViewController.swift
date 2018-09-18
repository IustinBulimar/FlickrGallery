import UIKit

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photosType: RemoteData.PhotosType = .recent(page: 1)
    
    var photos: [Photo] = []
    var pages = 1
    var nextPage = 1
    
    var animationAreaFrame: CGRect?
    var selectedIndexPath: IndexPath?
    
    var refreshControl = UIRefreshControl()
    
    
    static func storyboardInstance(photosType: RemoteData.PhotosType) -> GalleryViewController {
        let vc = storyboardInstance()
        vc.photosType = photosType
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideLoading()
        
        tableView.tableFooterView = UIView()
        tableView.register(cellClass: PhotoCell.self)
        tableView.rowHeight = 300
        tableView.dataSource = self
        tableView.delegate = self
        
        if case .search = photosType {
            searchBar.delegate = self
            searchBar.becomeFirstResponder()
        } else {
            let offset: CGFloat = searchBar.frame.height + UIApplication.shared.statusBarFrame.height
            searchBarTopConstraint.constant = -1 * offset
            
            refreshControl.tintColor = .primaryColor
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            tableView.refreshControl = refreshControl
            
            getNextPhotosPage()
        }
    }
    
    @objc func refresh() {
        getNextPhotosPage(reset: true)
    }
    
    func getNextPhotosPage(reset: Bool = true) {
        if case .favorites = photosType, !RemoteData.isAuthenticated {
            refreshControl.endRefreshing()
            return
        }
        var showLoading = false
        if reset {
            pages = 1
            nextPage = 1
            showLoading = photos.isEmpty
            photos = []
        }
        guard nextPage <= pages else { return }
        
        if showLoading {
            self.showLoading()
        }
        
        var type: RemoteData.PhotosType!
        switch photosType {
        case .recent:
            type = .recent(page: nextPage)
        case .favorites:
            type = .favorites(page: nextPage)
        case .search:
            type = .search(page: nextPage, text: searchBar.text ?? "")
        default:
            break
        }
        getPhotos(type: type)
    }
    
    func getPhotos(type: RemoteData.PhotosType) {
        RemoteData.getPhotos(type: type)
            .done { photosResponse in
                self.refreshControl.endRefreshing()
                self.hideLoading()
                self.photos += photosResponse.photos
                self.pages = photosResponse.pages
                self.nextPage = photosResponse.page + 1
                self.tableView.reloadData()
            }.catch { error in
                self.refreshControl.endRefreshing()
                self.hideLoading()
                print(error)
        }
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    func hideLoading() {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
}

extension GalleryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photo = photos[indexPath.row]
        let cell = tableView.dequeueReusableCell(ofType: PhotoCell.self, for: indexPath)
        cell.startLoading()
        cell.photoImageView.kf.setImage(with: URL(string: photo.url)!, placeholder: #imageLiteral(resourceName: "placeholder")) { image, error, cacheType, url in
            if let error = error {
                print(error)
            } else {
                cell.stopLoading()
            }
        }
        return cell
    }
    
}

extension GalleryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let photoViewerViewController = PhotoViewerViewController.storyboardInstance(url: photo.url, id: photo.id)
        photoViewerViewController.transitioningDelegate = self
        selectedIndexPath = indexPath
        present(photoViewerViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            getNextPhotosPage(reset: false)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard case .search = photosType else { return }
        
        let offset: CGFloat = searchBar.frame.height + UIApplication.shared.statusBarFrame.height
        let animationDuration = 0.2
        if abs(velocity.y) > 1 {
            if velocity.y > 0 {
                UIView.animate(withDuration: animationDuration) {
                    self.searchBarTopConstraint.constant = -1 * offset
                    self.view.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: animationDuration) {
                    self.searchBarTopConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
}

extension GalleryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        getNextPhotosPage(reset: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
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

