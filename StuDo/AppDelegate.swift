import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().tintColor = .globalTintColor
        
        let rootVC = RootViewController()
        RootViewController.main = rootVC
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = rootVC
        window!.makeKeyAndVisible()
        
        return true
    }
}
