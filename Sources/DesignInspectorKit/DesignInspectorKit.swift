import UIKit

/// The main entry point for DesignInspectorKit.
///
/// Use `DesignInspector.shared` to enable or disable the inspector globally.
/// When enabled, a two-finger tap gesture is automatically attached
/// to every view controller, allowing the user to activate the inspection overlay.
///
/// Example:
/// ```swift
/// DesignInspector.shared.enable()
/// ```
public final class DesignInspector {
    
    /// The shared singleton instance.
    public static let shared: DesignInspector = DesignInspector()
    
    /// Indicates whether the inspector is currently active.
    public private(set) var isEnabled: Bool = false
    
    /// The configuration used for all inspector overlays.
    /// Customize colors, token resolvers, and other appearance options here.
    public var configuration: InspectorConfiguration = .default
    
    private init() {}
    
    /// Enables the inspector globally by swizzling `viewDidAppear` on `UIViewController`.
    /// After calling this, a two-finger tap on any screen will present the inspector overlay.
    public func enable() {
        isEnabled = true
        DesignInspectorSwizzler.shared.enableGlobalSwizzling()
    }
    
    /// Disables the inspector globally and removes the swizzled behavior.
    public func disable() {
        isEnabled = false
        DesignInspectorSwizzler.shared.disableGlobalSwizzling()
    }

    /// Manually presents the inspector overlay for a specific view controller.
    /// - Parameter viewController: The view controller whose view will be inspected.
    public func inspect(viewController: UIViewController) {
        guard isEnabled else { return }
        guard !(viewController.presentedViewController is InspectorOverlayViewController) else { return }

        let navBar = (viewController as? UINavigationController)?.navigationBar
            ?? viewController.navigationController?.navigationBar

        let viewModel = InspectorViewModel(configuration: configuration)
        viewModel.activate()

        let inspectVC = InspectorOverlayViewController(
            targetView: viewController.view,
            navigationBar: navBar,
            viewModel: viewModel
        )

        inspectVC.modalPresentationStyle = .overFullScreen
        inspectVC.modalTransitionStyle = .crossDissolve
        viewController.present(inspectVC, animated: true)
    }
}
