import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var isAuthorized: Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let tabBarController = TabBarController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        if !isAuthorized {
            // TODO: Change it to the actual authorization view controller
            let authVC = UIViewController()
            authVC.view.backgroundColor = .white
            tabBarController.present(authVC, animated: true, completion: nil)
        }
        
        return true
    }


}

