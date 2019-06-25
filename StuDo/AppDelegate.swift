import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let tabBarController = TabBarController()
        
        if PersistentStore.shared.user == nil {
            let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
            
            let customViewController = storyboard.instantiateViewController(withIdentifier: "CustomViewController")
            
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = customViewController
            window?.makeKeyAndVisible()
            
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = tabBarController
            window?.makeKeyAndVisible()
        }
        
        return true
    }
}
