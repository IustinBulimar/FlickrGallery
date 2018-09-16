import Foundation

struct PhotosResponse: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case info = "photos"
    }
    
    var info: PhotosInfo
    
}

struct PhotosInfo: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case photos = "photo"
    }
    
    var photos: [Photo] = []
    
}

