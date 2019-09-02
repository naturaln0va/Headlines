
import UIKit

extension URLSession {
    
    typealias ImageCompletionBlock = (UIImage?) -> Void

    static func requestImage(at url: URL, size: CGSize, _ completion: @escaping ImageCompletionBlock) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            var image: UIImage?
            
            defer {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            
            guard let data = data else {
                return
            }
            
            guard let adjustedImage = UIImage(data: data)?.squareScale(to: size) else {
                return
            }
            
            image = adjustedImage
        }
        
        task.resume()
    }
    
}
