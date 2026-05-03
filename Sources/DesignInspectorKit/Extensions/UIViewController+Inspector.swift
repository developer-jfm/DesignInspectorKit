//
//  File.swift
//  DesignInspectorKit
//
//

import UIKit

extension UIViewController {
    
    private enum AssociatedKeys {
        static var inspectorGestureKey: UInt8 = 0
    }
    
    /// Attaches a two-finger tap gesture recognizer to this view controller.
    /// A single tap with **2 fingers** activates the inspector overlay.
    /// Has no effect if the gesture is already attached.
    public func enableDesignInspector() {
        guard objc_getAssociatedObject(self, &AssociatedKeys.inspectorGestureKey) == nil else { return }

        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleInspectorGesture(_:)))
        gesture.numberOfTouchesRequired = 2
        gesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(gesture)
        
        objc_setAssociatedObject(self, &AssociatedKeys.inspectorGestureKey, gesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// Removes the inspector two-finger tap gesture from this view controller.
    public func disableDesignInspector() {
        guard let gesture = objc_getAssociatedObject(self, &AssociatedKeys.inspectorGestureKey) as? UITapGestureRecognizer else { return }
        view.removeGestureRecognizer(gesture)
        objc_setAssociatedObject(self, &AssociatedKeys.inspectorGestureKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// Presents the inspector overlay using the shared `DesignInspector` configuration.
    public func showDesignInspector() {
        showDesignInspector(with: DesignInspector.shared.configuration)
    }
    
    /// Presents the inspector overlay with a custom configuration.
    /// Unlike `DesignInspector.inspect(viewController:)`, this method does not include
    /// the navigation bar in the inspectable area — it inspects only `self.view`.
    /// - Parameter configuration: The `InspectorConfiguration` to use for this overlay.
    public func showDesignInspector(with configuration: InspectorConfiguration) {
        let inspectorVC = InspectorOverlayViewController(targetView: view, configuration: configuration)
        inspectorVC.modalPresentationStyle = .overFullScreen
        inspectorVC.modalTransitionStyle = .crossDissolve
        present(inspectorVC, animated: true, completion: nil)
    }
    
    @objc private func handleInspectorGesture(_ gesture: UITapGestureRecognizer) {
        showDesignInspector()
    }

}
