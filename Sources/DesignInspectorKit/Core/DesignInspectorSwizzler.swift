//
//  File.swift
//  DesignInspectorKit
//
//

import UIKit

/// Handles method swizzling to automatically attach the inspector gesture
/// to every `UIViewController` when the inspector is globally enabled.
///
/// Swizzles `viewDidAppear(_:)` so that each view controller receives
/// the two-finger tap inspector gesture on its first appearance.
final class DesignInspectorSwizzler {
    
    static let shared = DesignInspectorSwizzler()
    
    private var isSwizzled: Bool = false
    
    private init() {}
    
    /// Swizzles `viewDidAppear(_:)` to inject the inspector gesture into all view controllers.
    /// Safe to call multiple times — swizzling only happens once.
    func enableGlobalSwizzling() {
        guard !isSwizzled else { return }
        swizzleViewDidAppear()
        isSwizzled = true
    }
    
    /// Restores the original `viewDidAppear(_:)` implementation.
    func disableGlobalSwizzling() {
        guard isSwizzled else { return }
        swizzleViewDidAppear()
        isSwizzled = false
    }
    
    private func swizzleViewDidAppear() {
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.inspector_viewDidAppear(_:))
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else {
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIViewController {
    
    private enum SwizzlingKey {
        static var inspectorEnableKey: UInt8 = 0
    }
    
    /// Swizzled replacement for `viewDidAppear(_:)`.
    /// Calls the original implementation and conditionally enables the inspector gesture.
    @objc func inspector_viewDidAppear(_ animated: Bool) {
        // After swizzling, this call resolves to the original viewDidAppear — NOT recursive.
        inspector_viewDidAppear(animated)

        guard DesignInspector.shared.isEnabled else { return }
        guard !isInspectorAlreadyEnabled else { return }
        guard shouldEnableInspector else { return }

        enableDesignInspector()
        isInspectorAlreadyEnabled = true
    }

    private var isInspectorAlreadyEnabled: Bool {
        get {
            return objc_getAssociatedObject(self, &SwizzlingKey.inspectorEnableKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &SwizzlingKey.inspectorEnableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var shouldEnableInspector: Bool {
        guard !(self is InspectorOverlayViewController) else { return false }
        let bundle = Bundle(for: type(of: self))
        let path = bundle.bundlePath
        let isSystemClass = bundle != Bundle.main
            && (path.contains("/System/") || path.contains("/Library/Frameworks/"))
        return !isSystemClass
    }
}
