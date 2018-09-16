import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        RemoteData.getRecentImages()
            .done { photosResponse in
                let photosUrls = photosResponse.info.photos.map { $0.url }
                print(photosUrls)
            }.catch { error in
                print(error)
        }
    }


}

