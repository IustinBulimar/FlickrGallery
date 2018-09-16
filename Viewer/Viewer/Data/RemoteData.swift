import Foundation
import PromiseKit

class RemoteData {
    
    enum FlickrMethod: String {
        case getRecent = "flickr.photos.getRecent"
    }
    
    private static let apiKey = "02e944b562f4779e04132e9007f789f3"
    
    private static func url(for method: FlickrMethod) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "method", value: method.rawValue),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]
        return components.url
    }
    
    private static func urlRequest(for method: FlickrMethod) throws -> URLRequest {
        guard let url = url(for: method) else {
            throw "Invalid URL"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    
    static func getRecentImages() -> Promise<PhotosResponse> {
        return firstly {
            URLSession.shared.dataTask(.promise, with: try urlRequest(for: .getRecent))
                .validate()
            }.map {
                try JSONDecoder().decode(PhotosResponse.self, from: $0.data)
        }
    }
    
    static func photoUrl(for photo: Photo) -> String {
        return "https://farm\(photo.farmId).staticflickr.com/\(photo.serverId)/\(photo.id)_\(photo.secret).jpg"
    }
    
}
