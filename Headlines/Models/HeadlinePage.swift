
import Foundation

struct HeadlinePage: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case status
        case totalResults
        case headlines = "articles"
    }

    let status: String
    let totalResults: Int
    let headlines: [Headline]
    
    var hasNextPage: Bool {
        // default page size is 20
        return totalResults > 20
    }
    
}
