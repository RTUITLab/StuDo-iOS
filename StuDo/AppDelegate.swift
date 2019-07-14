import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let tabBarController = TabBarController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        if GCIsUsingFakeData {
            PersistentStore.shared.user = User(id: "fakeUserID", firstName: "Fake", lastName: "Tester", email: "test@mail.com", studentID: nil, password: nil)
        } else if PersistentStore.shared.user == nil {
            let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
            
            let authVC = storyboard.instantiateViewController(withIdentifier: "CustomViewController")
            
            tabBarController.present(authVC, animated: false, completion: nil)
        }
        
        return true
    }
}
