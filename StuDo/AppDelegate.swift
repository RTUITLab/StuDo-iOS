import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabBarController: TabBarController!
    
    func presentInitialController(shouldAnimate: Bool) {
        
        if PersistentStore.shared.user == nil {
            let authVC = AuthorizationViewController()
            window!.rootViewController!.present(authVC, animated: shouldAnimate, completion: nil)
        } else {
            tabBarController = TabBarController()
            window!.rootViewController!.present(tabBarController, animated: false, completion: nil)
        }
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .white
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = rootVC
        window!.makeKeyAndVisible()
        
        presentInitialController(shouldAnimate: false)
        
        return true
    }
}
