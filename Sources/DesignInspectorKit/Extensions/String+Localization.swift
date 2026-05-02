//
//  File.swift
//  DesignInspectorKit
//
//  Created by Josimar Fiuza Melo on 30/04/26.
//

import Foundation

extension String {
    
    /// Returns the string looked up in `Localizable.strings` using the module bundle.
    /// Falls back to the key itself if no translation is found.
    var localized: String {
        NSLocalizedString(self, bundle: .module, comment: "")
    }
    
}

/// Typed constants for all localized string keys used by DesignInspectorKit.
/// Use these instead of raw strings to avoid typos and benefit from autocomplete.
public enum InspectorKey {
    
    // MARK: - General
    public static let title                 = "inspector.title".localized
    public static let close                 = "inspector.close".localized
    public static let tapToInspect          = "inspector.tap_to_inspect".localized
    public static let longPressToExit       = "inspector.long_press_to_exit".localized

    // MARK: - View Properties
    public static let frame                 = "inspector.frame".localized
    public static let background            = "inspector.background".localized
    public static let tintColor             = "inspector.tint_color".localized
    public static let alpha                 = "inspector.alpha".localized
    public static let cornerRadius          = "inspector.corner_radius".localized
    public static let borderWidth           = "inspector.border_width".localized
    public static let borderColor           = "inspector.border_color".localized

    // MARK: - Image Properties
    public static let image                 = "inspector.image".localized
    public static let imageSize             = "inspector.image_size".localized
    public static let imageRenderedSize     = "inspector.image_rendered_size".localized
    public static let contentMode           = "inspector.content_mode".localized

    // MARK: - Text Properties
    public static let text                  = "inspector.text".localized
    public static let font                  = "inspector.font".localized
    public static let textColor             = "inspector.text_color".localized
    public static let textAlignment         = "inspector.text_alignment".localized
    public static let numberOfLines         = "inspector.number_of_lines".localized

    // MARK: - Layout Properties
    public static let spacing               = "inspector.spacing".localized
    public static let spacingAbove          = "inspector.spacing_above".localized
    public static let spacingBelow          = "inspector.spacing_below".localized
    public static let spacingLeft           = "inspector.spacing_left".localized
    public static let spacingRight          = "inspector.spacing_right".localized
    public static let contentInsets         = "inspector.content_insets".localized
    public static let layoutMargins         = "inspector.layout_margins".localized

    // MARK: - Accessibility
    public static let accessibilityId       = "inspector.accessibility_id".localized
    public static let accessibilityLabel    = "inspector.accessibility_label".localized
    public static let accessibilityTraits   = "inspector.accessibility_traits".localized

    // MARK: - Hierarchy
    public static let subviewsCount         = "inspector.subviews_count".localized
    public static let depth                 = "inspector.depth".localized

    // MARK: - Constraints
    public static let constraints           = "inspector.constraints".localized
    public static let constraintActive      = "inspector.constraint_active".localized
    public static let constraintInactive    = "inspector.constraint_inactive".localized
}
