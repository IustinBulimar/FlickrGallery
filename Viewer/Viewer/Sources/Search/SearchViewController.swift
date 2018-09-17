import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var photos: [Photo] = []
    var page = 1
    var pages = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.register(cellClass: PhotoCell.self)
        tableView.rowHeight = 300
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
    }
    
    func getNextSearchPhotosPage() {
        guard page <= pages else { return }
        RemoteData.searchPhotos(text: searchBar.text ?? "", page: page)
            .done { photosResponse in
                self.photos += photosResponse.info.photos
                self.page = photosResponse.info.page + 1
                self.pages = photosResponse.info.pages
                self.tableView.reloadData()
            }.catch { error in
                print(error)
        }
    }
    
}

extension SearchViewController: UITableViewDataSource {
    
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

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let photoViewerViewController = PhotoViewerViewController.storyboardInstance(url: photo.url)
        present(photoViewerViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            getNextSearchPhotosPage()
        }
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        getNextSearchPhotosPage()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
}


