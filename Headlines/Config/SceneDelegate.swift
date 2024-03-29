
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            fatalError()
        }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        window.rootViewController = UINavigationController(rootViewController: HeadlinesViewController())
        window.makeKeyAndVisible()
    }

}

