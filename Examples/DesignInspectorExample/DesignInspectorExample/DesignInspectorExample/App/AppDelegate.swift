import UIKit
import DesignInspectorKit

/// App entry point.
/// Enables the DesignInspector globally so that every UIViewController
/// automatically receives the two-finger tap gesture to open the inspector overlay.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Enables the inspector on all view controllers via method swizzling.
        DesignInspector.shared.enable()
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
