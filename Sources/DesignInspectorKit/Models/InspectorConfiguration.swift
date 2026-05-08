//
//  File.swift
//  DesignInspectorKit
//
//

import UIKit

/// Configuration options for the DesignInspectorKit overlay.
///
/// Use `InspectorConfiguration.default` as a starting point and customize
/// appearance colors and design token resolvers as needed.
public struct InspectorConfiguration {
    
    // MARK: - Appearance
    
    /// The color used to highlight the selected view's frame.
    public var highlightColor: UIColor
    /// The color used for spacing annotation lines, labels, the info panel background tint, and the panel close button.
    public var annotationColor: UIColor
    /// The background color of the info panel.
    public var panelBackgroundColor: UIColor
    /// The primary text color used in the info panel.
    public var textColor: UIColor
    /// The secondary (label) text color used in the info panel.
    public var secondaryTextColor: UIColor
    /// The background color of the full-screen overlay. Defaults to semi-transparent black.
    public var overlayBackgroundColor: UIColor
    
    // MARK: - Token Resolvers
    
    /// Returns a design token name for a given `UIColor`. Used for background and text colors.
    public var colorTokenResolver: ((UIColor) -> String)?
    /// Returns a design token name for a `UIStackView` spacing value.
    public var stackSpacingTokenResolver: ((CGFloat) -> String)?
    /// Returns a design token name for a given `UIFont`.
    public var fontTokenResolver: ((UIFont) -> String)?
    /// Returns a design token name for a sibling spacing `CGFloat` value.
    public var spacingTokenResolver: ((CGFloat) -> String)?
    /// Returns a design token name for a given `UIImage`.
    public var imageTokenResolver: ((UIImage) -> String)?
    /// Returns an accessibility label string for a given `UIImage`.
    public var imageAccessibilityLabelResolver: ((UIImage) -> String)?
    
    public static let `default` = InspectorConfiguration(
        highlightColor: UIColor.systemBlue.withAlphaComponent(0.3),
        annotationColor: .systemBlue,
        panelBackgroundColor: .systemBackground,
        textColor: .label,
        secondaryTextColor: .secondaryLabel,
        overlayBackgroundColor: UIColor.black.withAlphaComponent(0.8),
        colorTokenResolver: nil,
        stackSpacingTokenResolver: nil,
        fontTokenResolver: nil,
        spacingTokenResolver: nil,
        imageTokenResolver: nil,
        imageAccessibilityLabelResolver: nil
    )
    
    // MARK: - Init
    
    public init(
        highlightColor: UIColor = UIColor.systemBlue.withAlphaComponent(0.3),
        annotationColor: UIColor = .systemBlue,
        panelBackgroundColor: UIColor = .systemBackground,
        textColor: UIColor = .label,
        secondaryTextColor: UIColor = .secondaryLabel,
        overlayBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8),
        colorTokenResolver: ((UIColor) -> String)? = nil,
        stackSpacingTokenResolver: ((CGFloat) -> String)? = nil,
        fontTokenResolver: ((UIFont) -> String)? = nil,
        spacingTokenResolver: ((CGFloat) -> String)? = nil,
        imageTokenResolver: ((UIImage) -> String)? = nil,
        imageAccessibilityLabelResolver: ((UIImage) -> String)? = nil
    ) {
        self.highlightColor = highlightColor
        self.annotationColor = annotationColor
        self.panelBackgroundColor = panelBackgroundColor
        self.textColor = textColor
        self.secondaryTextColor = secondaryTextColor
        self.overlayBackgroundColor = overlayBackgroundColor
        self.colorTokenResolver = colorTokenResolver
        self.stackSpacingTokenResolver = stackSpacingTokenResolver
        self.fontTokenResolver = fontTokenResolver
        self.spacingTokenResolver = spacingTokenResolver
        self.imageTokenResolver = imageTokenResolver
        self.imageAccessibilityLabelResolver = imageAccessibilityLabelResolver
    }

}
