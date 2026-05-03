import UIKit

/// Scene lifecycle delegate.
/// Builds the window and sets `ExampleListViewController` as the root,
/// wrapped in a `UINavigationController` for push navigation between examples.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Create the window and embed the root list inside a navigation controller.
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(
            rootViewController: ExampleListViewController()
        )
        window.makeKeyAndVisible()
        self.window = window
    }
}
