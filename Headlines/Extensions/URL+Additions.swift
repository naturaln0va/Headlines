
import Foundation

extension URL {
    
    var prettyHost: String? {
        let comps = URLComponents(url: self, resolvingAgainstBaseURL: true)
        
        guard var host = comps?.host else {
            return nil
        }
        
        if host.hasPrefix("www.") {
            host = host.replacingOccurrences(of: "www.", with: "")
        }
        
        return host
    }
    
}
