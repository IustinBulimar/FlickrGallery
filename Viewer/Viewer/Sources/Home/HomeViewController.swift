import UIKit

class HomeViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let popularViewController = GalleryViewController.storyboardInstance()
        popularViewController.tabBarItem = UITabBarItem(title: "Home", image: #imageLiteral(resourceName: "home_icon"), tag: 1)
        
        
        let searchViewController = SearchViewController.storyboardInstance()
        searchViewController.tabBarItem = UITabBarItem(title: "Search", image: #imageLiteral(resourceName: "search_icon"), tag: 2)
        
        setViewControllers([popularViewController, searchViewController],
                           animated: false)
    }
    
}
