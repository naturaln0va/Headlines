
import Foundation

struct Headline: Codable, Hashable {
    
    private enum CodingKeys: String, CodingKey {
        case author
        case title
        case description
        case url
        case urlToImage
        case date = "publishedAt"
    }
    
    let author: String?
    let title: String
    let description: String?
    let url: URL
    let urlToImage: String?
    let date: Date
    
    var imageURL: URL? {
        guard let urlString = urlToImage else {
            return nil
        }
        
        return URL(string: urlString)
    }
    
}
