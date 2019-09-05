
import Foundation

struct HeadlineError: Codable {
    
    let code: String
    let message: String
    
}

extension HeadlineError: CustomStringConvertible {
    
    var description: String {
        return "[\(code)] \(message)"
    }
    
}
