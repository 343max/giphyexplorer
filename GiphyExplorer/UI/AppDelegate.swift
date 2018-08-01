// Copyright Max von Webel. All Rights Reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

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
        
        let splitViewController = window!.rootViewController as! UISplitViewController
        let masterViewController = (splitViewController.viewControllers.first as! UINavigationController).topViewController as! MasterViewController
        masterViewController.client = client
        
        let detailNavigationController = splitViewController.viewControllers.last as! UINavigationController
        detailNavigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        return true
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            return true
        }
        return false
    }

}
