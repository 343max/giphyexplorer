// Copyright Max von Webel. All Rights Reserved.

import UIKit

class DarkSplitViewController: UISplitViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private lazy var apiKey: String = {
        guard let url = Bundle.main.url(forResource: "APIKey", withExtension: "plist") else {
            abort() // please create an APIKey.plist with a single String APIKey for your Giphy API Key in your bundle root
        }
        let dict = NSDictionary(contentsOf: url) as! Dictionary<String, String>
        return dict["APIKey"]!
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let networkingClient = GiphyNetworkingClient(apiKey: apiKey)
        let client = GiphyClient(client: networkingClient)
        
        window?.tintColor = UIColor.orange
        
        let masterViewController = (window?.rootViewController as! UINavigationController).topViewController as! MasterViewController
        masterViewController.client = client
        return true
    }
}

