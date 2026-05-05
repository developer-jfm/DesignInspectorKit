//
//  File.swift
//  DesignInspectorKit
//
//

import UIKit

/// A snapshot of all inspectable properties of a `UIView` at the time of inspection.
/// Produced by `ViewHierarchyInspector` and consumed by the inspector overlay UI.
public struct ViewInspectorInfo {

    // MARK: - Basic Info
    
    /// The class name of the inspected view (e.g. `"UILabel"`, `"UIButton"`).
    public let className: String
    /// The frame of the view in its superview's coordinate space.
    public let frame: CGRect
    /// The frame of the view converted to the window's coordinate space. Equals `frame` if the view has no superview.
    public let frameInWindow: CGRect
    /// The depth level of the view in the hierarchy (root = 0).
    public let depth: Int
    
    // MARK: - View Properties
    
    /// The background color of the view, if set.
    public let backgroundColor: UIColor?
    /// The design token name resolved for the background color, if a resolver is configured.
    public let backgroundColorToken: String?
    /// The tint color of the view.
    public let tintColor: UIColor?
    /// The corner radius of the view's layer.
    public let cornerRadius: CGFloat
    /// The border width of the view's layer.
    public let borderWidth: CGFloat
    /// The border color of the view's layer, if set.
    public let borderColor: UIColor?
    /// The alpha value of the view (0.0–1.0).
    public let alpha: CGFloat
    
    // MARK: - Image Properties
    
    /// The resolved name or token of the image, if the view is a `UIImageView`.
    public let imageName: String?
    /// The design token name resolved for the image asset, if a resolver is configured.
    public let imageNameToken: String?
    /// The intrinsic size of the image asset.
    public let imageSize: CGSize?
    /// The rendered size of the image within the image view's bounds.
    public let imageRenderedSize: CGSize?
    /// The content mode of the image view.
    public let contentMode: UIView.ContentMode?
    
    // MARK: - Text Properties
    
    /// The text content of the view, if the view is a `UILabel`, `UITextField`, or `UITextView`.
    public let text: String?
    /// The font used by the view, if applicable.
    public let font: UIFont?
    /// The design token name resolved for the font, if a resolver is configured.
    public let fontToken: String?
    /// The text color of the view, if applicable.
    public let textColor: UIColor?
    /// The design token name resolved for the text color, if a resolver is configured.
    public let textColorToken: String?
    /// The text alignment, if applicable.
    public let textAlignment: NSTextAlignment?
    /// The maximum number of lines, if the view is a `UILabel`.
    public let numberOfLines: Int?
    
    // MARK: - Layout Properties
    
    /// The spacing value, if the view is a `UIStackView`.
    public let spacing: CGFloat?
    /// The design token name resolved for the spacing value, if a resolver is configured.
    public let spacingToken: String?
    /// The axis of the stack view (`horizontal` or `vertical`), if applicable.
    public let stackAxis: NSLayoutConstraint.Axis?
    /// The distribution of the stack view, if applicable.
    public let stackDistribution: UIStackView.Distribution?
    /// The alignment of the stack view, if applicable.
    public let stackAlignment: UIStackView.Alignment?
    /// The content insets, if the view is a `UIScrollView` or `UIButton`.
    public let contentInsets: UIEdgeInsets?
    /// The content size of the scroll view, if applicable.
    public let scrollContentSize: CGSize?
    /// Whether paging is enabled on the scroll view, if applicable.
    public let scrollIsPagingEnabled: Bool?
    /// The layout margins of the view.
    public let layoutMargin: UIEdgeInsets
    /// The Auto Layout constraints directly owned by the view, serialized as `ConstraintInfo` snapshots.
    public let constraints: [ConstraintInfo]
    
    // MARK: - Accessibility
    
    /// The accessibility identifier of the view.
    public let accessibilityIdentifier: String?
    /// The accessibility label of the view.
    public let accessibilityLabel: String?
    /// The accessibility traits of the view.
    public let accessibilityTraits: UIAccessibilityTraits
    /// Whether the view is an accessibility element.
    public let isAccessibilityElement: Bool
    
    // MARK: - Control State (UISwitch / UISlider / UIProgressView / UIActivityIndicator)
    
    /// Whether the switch is on, if the view is a `UISwitch`.
    public let switchIsOn: Bool?
    /// The on-tint color of the switch, if applicable.
    public let switchOnTintColor: UIColor?
    /// The thumb tint color of the switch, if applicable.
    public let switchThumbTintColor: UIColor?
    /// The minimum value of the slider, if applicable.
    public let sliderMinValue: Float?
    /// The maximum value of the slider, if applicable.
    public let sliderMaxValue: Float?
    /// The current value of the slider, if applicable.
    public let sliderValue: Float?
    /// The progress value (0.0–1.0) of a progress view, if applicable.
    public let progressValue: Float?
    /// The progress tint color, if applicable.
    public let progressTintColor: UIColor?
    /// Whether an activity indicator is currently animating, if applicable.
    public let activityIsAnimating: Bool?
    
    // MARK: - UISearchBar

    /// The placeholder text of the search bar, if applicable.
    public let searchBarPlaceholder: String?
    /// The current text in the search bar, if applicable.
    public let searchBarText: String?
    /// The style of the search bar, if applicable.
    public let searchBarStyle: UISearchBar.Style?
    /// Whether the cancel button is shown, if applicable.
    public let searchBarShowsCancelButton: Bool?
    /// The bar tint color of the search bar, if applicable.
    public let searchBarTintColor: UIColor?

    // MARK: - Hierarchy

    /// The number of direct subviews.
    public let subviewsCount: Int
    /// A weak reference to the original inspected view.
    public weak var view: UIView?

    // MARK: - Convenience

    /// Whether the inspected view is a `UIControl` (UIButton, UISwitch, UISlider, etc.).
    public var isControl: Bool { view is UIControl }
    /// Whether the inspected view is a `UIImageView`.
    public var isImageView: Bool { view is UIImageView }

}

/// A simplified, serializable representation of a single `NSLayoutConstraint`.
public struct ConstraintInfo {
    
    /// The first attribute name (e.g. `"leading"`, `"width"`).
    public let attribute: String
    /// The relation symbol (`"=="`, `"<="`, `">="`).
    public let relation: String
    /// The constant value of the constraint.
    public let constant: CGFloat
    /// The multiplier of the constraint.
    public let multiplier: CGFloat
    /// The layout priority as a raw float value.
    public let priority: Float
    /// Whether the constraint is currently active.
    public let isActive: Bool
    
    /// A human-readable summary of the constraint.
    public var description: String {
        return "\(attribute) \(relation) \(constant) @ \(Int(priority))"
    }
    
}
