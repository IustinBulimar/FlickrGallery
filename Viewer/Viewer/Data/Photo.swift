import Foundation

struct Photo: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case farmId = "farm"
        case serverId = "server"
        case id
        case secret
        case title
    }
    
    var farmId = 0
    var serverId = ""
    var id = ""
    var secret = ""
    var title = ""
    
    var url: String {
        return RemoteData.photoUrl(for: self)
    }
    
}
