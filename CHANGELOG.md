# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.4.0] - 2026-05

### Added
- `deepestInspectableView(atWindowPoint:)` — window-space frame traversal that penetrates `UITableViewCell`, `UIListContentView`, and other containers that block standard hit-testing on iOS 26
- `UITableView` example screen with 12 cells containing SF Symbol image and label

### Fixed
- `UIImageView` and `UILabel` inside `UITableViewCell` are now inspectable on iOS 26
- `UISearchBar` subviews (`UITextField`, search icon) are now inspectable on iOS 26
- Internal UIKit private views (`UITouchPassthroughView`, `UISearchBarBackground`, `_UI*`) are skipped as inspection results but their subviews are still traversed
- iOS 13–18 regression: `handleTap` now uses `#available(iOS 19.0, *)` to restore original `deepestView(at:)` behaviour on older OS versions
- `defaultContentConfiguration()` in example app now guarded with `#available(iOS 14.0, *)`

## [1.3.0] - 2026-05

### Added
- `UISearchBar` inspection: placeholder, search text, style, cancel button visibility, bar tint color
- `SearchBarExampleViewController` in example app with 4 search bar variations
- 6 unit tests for `UISearchBar` inspection

### Fixed
- `imageView.accessibilityIdentifier` now takes priority over `image.accessibilityIdentifier` in name resolution

## [1.2.0] - 2026-05

### Fixed
- Image name now correctly extracted from `UIImage.description` for SF Symbols and asset catalog images
- Replaced deprecated `contentEdgeInsets` with `UIButton.Configuration` on iOS 15+

### Tests
- Added 4 unit tests for `UIImageView` inspection: SF Symbol name, image size, content mode, and isolation

## [1.1.0] - 2026-05

### Fixed
- Image name was not displayed in the inspector panel for `UIImageView` elements — now resolved via SF Symbol name and `UIImageAsset` catalog name before falling back to generic dimensions

### Added
- Haptic feedback (light impact) when selecting a view for inspection
- Swipe-to-dismiss gesture on the info panel (swipe up to close)
- Dimming overlay effect when the info panel is visible
- Background and border styling on spacing value labels for better readability
- Centered text alignment on spacing constraint labels
- MIT License file

### Changed
- `frameInWindow` type changed from `CGRect?` to `CGRect` (non-optional)
- `contentStackview` renamed to `contentStackView` (proper camelCase)
- Spacing token display now uses `Int()` for cleaner numeric values (e.g., "8pt" instead of "8.0pt")
- `borderColor` only displays when `borderWidth > 0`
- `tintColor` only displays for `UIControl` and `UIImageView` types
- `UIColor.hexString` now converts to sRGB color space before extracting components (fixes issues with gray/white colors)
- Improved safety in `UIColor+Hex.swift` — removed force unwrap on `CGColorSpace.sRGB`

### Fixed
- Missing `bottomAnchor` constraint on `labelView` in `addInfoRow` (no-swatch branch)
- Trailing whitespace in multiple files
- Force unwrap (`!`) in `UIColor.hexString` color space conversion
- Documentation now clarifies that `showDesignInspector(with:)` does not include navigation bar in inspectable area

## [1.0.0] - 2026-04

### Added
- Initial release of DesignInspectorKit
- Interactive overlay for visual inspection of iOS interfaces
- Two-finger tap gesture to activate inspector
- Property inspection panel with scrollable content
- Support for inspecting:
  - UIView properties (frame, background color, tint, alpha, corner radius, border)
  - UILabel properties (text, font, color, alignment, number of lines)
  - UIImageView properties (image name, size, rendered size, content mode)
  - UIStackView properties (axis, distribution, alignment, spacing)
  - UIScrollView properties (content size, paging)
  - UISwitch, UISlider, UIProgressView, UIActivityIndicatorView states
  - Accessibility properties (identifier, label, traits, isAccessibilityElement)
  - Layout constraints and spacing annotations
- Visual indicators with consistent color language (blue for spacing, red for panel)
- Dark mode support
- Localization support (English, Portuguese Brazil, Spanish)
- Swift Package Manager distribution
- Token resolvers for design system integration (color, spacing, font, image tokens)
- Configuration system for customizing appearance and behavior
- Example app demonstrating all features
- Comprehensive test coverage for color utilities and constraint parsing
