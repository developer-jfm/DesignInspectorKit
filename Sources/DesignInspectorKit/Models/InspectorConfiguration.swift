//
//  File.swift
//  DesignInspectorKit
//
//  Created by Josimar Fiuza Melo on 30/04/26.
//

import Foundation
import UIKit

/// Configuration options for the DesignInspectorKit overlay.
///
/// Use `InspectorConfiguration.default` as a starting point and customize
/// appearance colors and design token resolvers as needed.
public struct InspectorConfiguration {
    
    // MARK: - Appearance
    
    /// The color used to highlight the selected view's frame.
    public var highlightColor: UIColor
    /// The color used for spacing annotation lines and labels.
    public var annotationColor: UIColor
    /// The background color of the info panel.
    public var panelBackgroundColor: UIColor
    /// The primary text color used in the info panel.
    public var textColor: UIColor
    /// The secondary (label) text color used in the info panel.
    public var secondaryTextColor: UIColor
    
    // MARK: - Token Resolvers
    
    /// Returns a design token name for a given `UIColor`. Used for background and text colors.
    public var colorTokenColorResolver: ((UIColor) -> String)?
    /// Returns a design token name for a spacing `CGFloat` value (e.g. stack view spacing).
    public var spacingTokenColorResolver: ((CGFloat) -> String)?
    /// Returns a design token name for a given `UIFont`.
    public var fontTokenColorResolver: ((UIFont) -> String)?
    /// Returns a design token name for a sibling spacing `CGFloat` value.
    public var spacingTokenResolver: ((CGFloat) -> String)?
    /// Returns a design token name for a given `UIImage`.
    public var imageTokenResolver: ((UIImage) -> String)?
    /// Returns an accessibility label string for a given `UIImage`.
    public var imageAcessibilityLabelResolver: ((UIImage) -> String)?
    
    public static let `default` = InspectorConfiguration(
        highlightColor: UIColor.systemBlue.withAlphaComponent(0.3),
        annotationColor: .systemRed,
        panelBackgroundColor: .systemBackground,
        textColor: .label,
        secondaryTextColor: .secondaryLabel,
        colorTokenColorResolver: nil,
        spacingTokenColorResolver: nil,
        fontTokenColorResolver: nil,
        spacingTokenResolver: nil,
        imageTokenResolver: nil,
        imageAcessibilityLabelResolver: nil
    )
    
    //MARK - Initi
    
    public init(
        highlightColor: UIColor = UIColor.systemBlue.withAlphaComponent(0.3),
        annotationColor: UIColor = .systemRed,
        panelBackgroundColor: UIColor = .white,
        textColor: UIColor = .darkGray,
        secondaryTextColor: UIColor = .gray,
        colorTokenColorResolver: ((UIColor) -> String)? = nil,
        spacingTokenColorResolver: ((CGFloat) -> String)? = nil,
        fontTokenColorResolver: ((UIFont) -> String)? = nil,
        spacingTokenResolver: ((CGFloat) -> String)? = nil,
        imageTokenResolver: ((UIImage) -> String)? = nil,
        imageAcessibilityLabelResolver: ((UIImage) -> String)? = nil
    ) {
        self.highlightColor = highlightColor
        self.annotationColor = annotationColor
        self.panelBackgroundColor = panelBackgroundColor
        self.textColor = textColor
        self.secondaryTextColor = secondaryTextColor
        self.colorTokenColorResolver = colorTokenColorResolver
        self.spacingTokenColorResolver = spacingTokenColorResolver
        self.fontTokenColorResolver = fontTokenColorResolver
        self.spacingTokenResolver = spacingTokenResolver
        self.imageTokenResolver = imageTokenResolver
        self.imageAcessibilityLabelResolver = imageAcessibilityLabelResolver
    }
    
}
