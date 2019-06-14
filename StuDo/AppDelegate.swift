import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var isAuthorized: Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // API Demo
        
        let client = APIClient()
        client.delegate = self
        client.login(withCredentials: Credentials(email: "test@gmail.com", password: "123456"))
        
        let user = User(id: nil, firstName: "Alex", lastName: "Lawther", email: "alexxx@mail.com", studentID: nil, password: "alexa")
        client.register(user: user)
        
        // --- end
        
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



// MARK:- API Demo

extension AppDelegate: APIClientDelegate {
    func apiClient(_ client: APIClient, didFinishLoginRequest request: APIRequest, andRecievedUser user: User) {
        print("ID: \(user.id!)")
        print("Name: \(user.firstName)")
        print("Surname: \(user.lastName)")
        print("Request to \(request.path) succeeded")
    }
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print("Request to \(request.path) failed with error: \(error.localizedDescription)")
    }
}

// --- end
