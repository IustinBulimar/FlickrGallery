import UIKit
import PromiseKit
import OAuthSwift
import SafariServices
import KeychainSwift

class RemoteData {
    
    enum PhotosType {
        case recent(page: Int)
        case popular(page: Int)
        case search(page: Int, text: String)
        
        var method: String {
            switch self {
            case .recent: return "flickr.photos.getRecent"
            case .popular: return "flickr.photos.getPopular"
            case .search: return "flickr.photos.search"
            }
        }
        
        var params: [String: String] {
            var defaultParams = [
                "api_key": apiKey,
                "method": method,
                "format": "json",
                "nojsoncallback": "1",
                "sort": "relevance",
                "content_type": "1",
                "per_page": "20"
            ]
            switch self {
            case .recent(let page):
                defaultParams["page"] = "\(page)"
                
            case .popular(let page):
                defaultParams["page"] = "\(page)"
                
            case .search(let page, let text):
                defaultParams["page"] = "\(page)"
                defaultParams["text"] = text
            }
            return defaultParams
        }
    }
    
    private static let apiKey = "02e944b562f4779e04132e9007f789f3"
    private static let apiSecret = "3f869ed599da8ad8"
    
    private static var oauth: OAuth1Swift!
    
    static func authenticate(viewController: UIViewController) {
        oauth = OAuth1Swift(
            consumerKey: apiKey,
            consumerSecret: apiSecret,
            requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
            authorizeUrl: "https://www.flickr.com/services/oauth/authorize",
            accessTokenUrl: "https://www.flickr.com/services/oauth/access_token"
        )
        
        let keychain = KeychainSwift()
        if let oauthToken = keychain.get("oauthToken"),
            let oauthTokenSecret = keychain.get("oauthTokenSecret") {
            oauth.client.credential.oauthToken = oauthToken
            oauth.client.credential.oauthTokenSecret = oauthTokenSecret
        } else {
            let handler = SafariURLHandler(viewController: viewController, oauthSwift: self.oauth!)
            handler.factory = { url in
                let controller = SFSafariViewController(url: url)
                return controller
            }
            oauth.authorizeURLHandler = handler
            let _ = oauth.authorize(withCallbackURL: URL(string: "Viewer://oauth-callback/flickr")!,
                                    success: { credential, response, parameters in
                                        let keychain = KeychainSwift()
                                        keychain.set(oauth.client.credential.oauthToken, forKey: "oauthToken")
                                        keychain.set(oauth.client.credential.oauthTokenSecret, forKey: "oauthTokenSecret")
            },
                                    failure: { error in
                                        print(error.description)
            })
        }
    }
    
    static func getPhotos(type: PhotosType) -> Promise<PhotosResponse> {
        return Promise { seal in
            _ = self.oauth.client.get("https://api.flickr.com/services/rest",
                                      parameters: type.params,
                                      success: { response in
                                        do {
                                            let photosResponse = try JSONDecoder().decode(PhotosResponse.self, from: response.data)
                                            seal.fulfill(photosResponse)
                                        } catch {
                                            seal.reject(error)
                                        }
            },
                                      failure: { error in
                                        seal.reject(error)
            })
        }
    }
    
    static func photoUrl(for photo: Photo) -> String {
        return "https://farm\(photo.farmId).staticflickr.com/\(photo.serverId)/\(photo.id)_\(photo.secret)_b.jpg"
    }
    
}
