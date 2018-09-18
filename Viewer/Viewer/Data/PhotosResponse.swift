import Foundation

struct PhotosResponse: Codable {

    private enum CodingKeys: String, CodingKey {
        case photos = "photo"
        case page
        case pages
    }
    
    var photos: [Photo] = []
    var page = 0
    var pages = 0
    
}

