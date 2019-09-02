
import Foundation

struct HeadlineError: Codable {
    
    let code: String
    let message: String
    
    var isMaximumResultsReached: Bool {
        return code == "maximumResultsReached"
    }
    
}

extension HeadlineError: CustomStringConvertible {
    
    var description: String {
        return "[\(code)] \(message)"
    }
    
}
