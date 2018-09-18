import UIKit

class HomeViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RemoteData.authenticate(viewController: self)
            .done {
                print("Authenticated")
            }.catch { error in
                print(error)
        }
        
        let popularViewController = GalleryViewController.storyboardInstance(photosType: .recent(page: 1))
        popularViewController.tabBarItem = UITabBarItem(title: "Home", image: #imageLiteral(resourceName: "home_icon"), tag: 1)
        
        
        let searchViewController = SearchViewController.storyboardInstance()
        searchViewController.tabBarItem = UITabBarItem(title: "Search", image: #imageLiteral(resourceName: "search_icon"), tag: 2)
        
        let favoritesViewController = GalleryViewController.storyboardInstance(photosType: .favorites(page: 1))
        favoritesViewController.tabBarItem = UITabBarItem(title: "Favorites", image: #imageLiteral(resourceName: "favorite"), tag: 3)
        
        setViewControllers([popularViewController, searchViewController, favoritesViewController],
                           animated: false)
    }
    
}
