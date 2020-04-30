import UIKit

class HomeViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RemoteData.restoreAuthentication().done {
            print("Was signed in")
        }.catch { error in
            print(error)
        }
        
        let popularViewController = GalleryViewController.storyboardInstance(photosType: .recent(page: 1))
        popularViewController.tabBarItem = UITabBarItem(title: "Home", image: #imageLiteral(resourceName: "home_icon"), tag: 1)
        
        let searchViewController = GalleryViewController.storyboardInstance(photosType: .search(page: 1, text: ""))
        searchViewController.tabBarItem = UITabBarItem(title: "Search", image: #imageLiteral(resourceName: "search_icon"), tag: 2)
        
        let favoritesViewController = GalleryViewController.storyboardInstance(photosType: .favorites(page: 1))
        favoritesViewController.tabBarItem = UITabBarItem(title: "Favorites", image: #imageLiteral(resourceName: "favorite"), tag: 3)
        
        let profileViewController = ProfileViewController.storyboardInstance()
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: #imageLiteral(resourceName: "profile"), tag: 4)
        
        setViewControllers([
            popularViewController,
            searchViewController,
            favoritesViewController,
            profileViewController
            ],
                           animated: false)
    }
    
}
