//
//  File.swift
//  DesignInspectorKit
//
//

import UIKit

extension UIView {

    /// Returns a flat array of all subviews recursively. Does not include the receiver itself.
    func allSubviews() -> [UIView] {
        var result = subviews
        for subview in subviews {
            result.append(contentsOf: subview.allSubviews())
        }
        return result
    }
    
    /// Returns the deepest subview that contains the given point in the receiver's coordinate space.
    /// Traverses subviews in reverse order (front to back) to match the visual hit-test order.
    /// Skips hidden, zero-alpha, and clipped-out views to match UIKit's native hit-test behaviour.
    /// - Parameter point: The point in the receiver's coordinate space.
    /// - Returns: The deepest subview containing the point, or `self` if no subview matches.
    public func deepestView(at point: CGPoint) -> UIView? {
        guard !isHidden, alpha > 0.01 else { return nil }
        guard bounds.contains(point) || !clipsToBounds else { return nil }

        for subview in subviews.reversed() {
            guard !subview.isHidden, subview.alpha > 0.01 else { continue }
            let convertedPoint = convert(point, to: subview)
            if let found = subview.deepestView(at: convertedPoint) {
                return found
            }
        }

        return bounds.contains(point) ? self : nil
    }

    /// Returns `true` if this view is an internal UIKit container that should be
    /// skipped as a result but whose subviews should still be traversed.
    private var isSkippableContainer: Bool {
        let className = String(describing: type(of: self))
        let skippable = [
            "UISearchBarBackground",
            "UISearchBarPromptCanvasView",
            "UITouchPassthroughView",
            "UIDropShadowView",
            "UITransitionView",
            "UILayoutContainerView",
            "UINavigationTransitionView",
            "_UIParallaxDimmingView",
            "_UIBarBackground",
            "_UISystemBackgroundView",
        ]
        return skippable.contains(className) || className.hasPrefix("_UI")
    }

    /// Returns the deepest inspectable subview whose frame (converted to window coordinates)
    /// contains the given window-space point.
    /// Unlike `deepestView(at:)` and `hitTest(_:with:)`, this method ignores `clipsToBounds`
    /// and `isUserInteractionEnabled`, allowing it to penetrate into `UITableViewCell`,
    /// `UIListContentView`, and other containers that block standard hit-testing.
    /// Skips internal UIKit private containers as results but still traverses their subviews.
    /// - Parameter windowPoint: The point in the window's coordinate space.
    /// - Returns: The deepest subview whose window frame contains the point, or `nil`.
    public func deepestInspectableView(atWindowPoint windowPoint: CGPoint) -> UIView? {
        guard !isHidden, alpha > 0.01 else { return nil }
        guard frameInWindow.contains(windowPoint) else { return nil }

        for subview in subviews.reversed() {
            if let found = subview.deepestInspectableView(atWindowPoint: windowPoint) {
                return found
            }
        }

        return isSkippableContainer ? nil : self
    }
    
    /// The frame of the view converted to the window's coordinate space.
    /// Returns the view's own frame if it has no window or superview.
    public var frameInWindow: CGRect {
        if let window = window {
            return convert(bounds, to: window)
        }
        return superview?.convert(frame, to: nil) ?? frame
    }
            
    /// The vertical distance from the top edge of this view to the bottom edge
    /// of the nearest sibling view positioned above it.
    /// Returns `nil` if there is no superview or no sibling above.
    public var spacingToSiblingAbove: CGFloat? {
        guard let superview = superview else { return nil }
        
        let siblings = superview.subviews.filter { $0 !== self && $0.frame.maxY <= frame.minY }
        
        guard let nearestAbove = siblings.max(by: { $0.frame.maxY < $1.frame.maxY }) else { return nil }
        return frame.minY - nearestAbove.frame.maxY
    }
    
    /// The vertical distance from the bottom edge of this view to the top edge
    /// of the nearest sibling view positioned below it.
    /// Returns `nil` if there is no superview or no sibling below.
    public var spacingToSiblingBelow: CGFloat? {
        guard let superview = superview else { return nil }
        
        let siblings = superview.subviews.filter { $0 !== self && $0.frame.minY >= frame.maxY }
        
        guard let nearestBelow = siblings.min(by: { $0.frame.minY < $1.frame.minY }) else { return nil }
        return nearestBelow.frame.minY - frame.maxY
    }
        
    /// The horizontal distance from the left edge of this view to the right edge
    /// of the nearest sibling view positioned to its left.
    /// Returns `nil` if there is no superview or no sibling to the left.
    public var spacingToSiblingLeft: CGFloat? {
        guard let superview = superview else { return nil }
        
        let siblings = superview.subviews.filter { $0 !== self && $0.frame.maxX <= frame.minX }
        
        guard let nearestLeft = siblings.max(by: { $0.frame.maxX < $1.frame.maxX }) else { return nil }
        return frame.minX - nearestLeft.frame.maxX
    }
    
    /// The horizontal distance from the right edge of this view to the left edge
    /// of the nearest sibling view positioned to its right.
    /// Returns `nil` if there is no superview or no sibling to the right.
    public var spacingToSiblingRight: CGFloat? {
        guard let superview = superview else { return nil }
        
        let siblings = superview.subviews.filter { $0 !== self && $0.frame.minX >= frame.maxX }
        
        guard let nearestRight = siblings.min(by: { $0.frame.minX < $1.frame.minX }) else { return nil }
        return nearestRight.frame.minX - frame.maxX
    }
    
    /// The distances from each edge of this view to the corresponding edge of its superview.
    /// Returns `nil` if the view has no superview.
    public var spacingToSuperView: UIEdgeInsets? {
        guard let superview = superview else { return nil }
        
        return UIEdgeInsets(
            top: frame.minY,
            left: frame.minX,
            bottom: superview.bounds.height - frame.maxY,
            right: superview.bounds.width - frame.maxX
        )
    }
    
}
