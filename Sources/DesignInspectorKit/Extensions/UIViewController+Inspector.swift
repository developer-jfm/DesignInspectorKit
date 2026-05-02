//
//  File.swift
//  DesignInspectorKit
//
//  Created by Josimar Fiuza Melo on 30/04/26.
//

import UIKit
import Foundation

extension UIViewController {
    
    private enum AssociatedKeys {
        static var inspectorGestureKey: UInt8 = 0
    }
    
    /// Attaches a long-press gesture recognizer (2 seconds) to this view controller.
    /// When triggered, presents the inspector overlay.
    /// Has no effect if the gesture is already attached.
    public func enableDesignInspector() {
        guard objc_getAssociatedObject(self, &AssociatedKeys.inspectorGestureKey) == nil else { return }
        
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleInspectorGesture(_:)))
        gesture.minimumPressDuration = 2
        view.addGestureRecognizer(gesture)
        
        objc_setAssociatedObject(self, &AssociatedKeys.inspectorGestureKey, gesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// Removes the inspector long-press gesture from this view controller.
    public func disableDesignInspector() {
        guard let gesture = objc_getAssociatedObject(self, &AssociatedKeys.inspectorGestureKey) as? UILongPressGestureRecognizer else { return }
        view.removeGestureRecognizer(gesture)
        objc_setAssociatedObject(self, &AssociatedKeys.inspectorGestureKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// Presents the inspector overlay using the shared `DesignInspector` configuration.
    public func showDesignInspector() {
        showDesignInspector(with: DesignInspector.shared.configuration)
    }
    
    /// Presents the inspector overlay with a custom configuration.
    /// - Parameter configuration: The `InspectorConfiguration` to use for this overlay.
    public func showDesignInspector(with configuration: InspectorConfiguration) {
        let inspectorVC = InspectorOverlayViewController(targetView: view, configuration: configuration)
        inspectorVC.modalPresentationStyle = .overFullScreen
        inspectorVC.modalTransitionStyle = .crossDissolve
        present(inspectorVC, animated: true, completion: nil)
    }
    
    @objc private func handleInspectorGesture(_ gesture: UILongPressGestureRecognizer) {
        showDesignInspector()
    }
        
}


