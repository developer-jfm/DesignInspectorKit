# DesignInspectorKit

A Swift library for visual inspection and debugging of iOS interfaces. Tap any view at runtime to inspect its layout, colors, fonts, spacing, constraints, accessibility properties, and control state through an interactive overlay — with full dark mode support.

## Requirements

- iOS 13.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/developer-jfm/DesignInspectorKit.git", from: "1.2.0")
]
```

Or via Xcode: **File → Add Package Dependencies...**

## Usage

### Enable globally (auto-attaches to all view controllers)

```swift
import DesignInspectorKit

DesignInspector.shared.enable()
```

Once enabled, **tap with 2 fingers** on any screen to activate the overlay, then **tap any view** to inspect it.

> **Simulator tip:** Hold **Option ⌥** while clicking to simulate two simultaneous touches.

### Enable manually on a specific view controller

```swift
viewController.enableDesignInspector()
```

### Present programmatically

```swift
DesignInspector.shared.inspect(viewController: self)
```

### Custom configuration

```swift
var config = InspectorConfiguration.default
config.highlightColor = UIColor.systemGreen.withAlphaComponent(0.3)
config.colorTokenResolver = { color in
    return DesignTokens.name(for: color)
}
config.fontTokenResolver = { font in
    return DesignTokens.name(for: font)
}
config.spacingTokenResolver = { spacing in
    return DesignTokens.name(for: spacing)
}
DesignInspector.shared.configuration = config
```

## Inspected Properties

The inspector panel shows the following properties for each tapped view:

| Category | Properties |
|----------|-----------|
| **Layout** | Frame, Corner Radius, Border Width/Color, Alpha, Layout Margins |
| **Colors** | Background, Tint (with design token support) |
| **Text** | Content, Font, Text Color, Alignment, Number of Lines (UILabel, UIButton, UITextField, UITextView) |
| **Image** | Name/token, Intrinsic size, Rendered size, Content mode (UIImageView) |
| **UIStackView** | Axis, Distribution, Alignment, Spacing |
| **UIScrollView** | Content size, Content insets, Paging enabled |
| **UISwitch** | Is on, On tint color, Thumb tint color |
| **UISlider** | Current value, Min/Max range |
| **UIProgressView** | Progress %, Progress tint color |
| **UIActivityIndicatorView** | Is animating |
| **UISearchBar** | Placeholder, Search text, Style, Cancel button visibility, Bar tint color |
| **Accessibility** | Identifier, Label, Traits, Is accessibility element |
| **Sibling Spacing** | Distance to nearest sibling above, below, left, right |

## Screenshots

### Activation
Tap with 2 fingers on any screen to activate the overlay.

| Before | Overlay active |
|--------|---------------|
| ![App screen](docs/screenshots/01_before.png) | ![Overlay active](docs/screenshots/02_overlay.png) |

---

### Inspecting a view
Tap any view to highlight it and open the info panel.

| View selected | Info panel |
|--------------|-----------|
| ![View selected](docs/screenshots/03_selected.png) | ![Info panel](docs/screenshots/04_panel.png) |

---

### Control inspection
UISwitch, UISlider, UIProgressView and UIActivityIndicatorView properties.

![Controls](docs/screenshots/05_controls.png)

---

### Accessibility inspection
`accessibilityLabel`, `accessibilityIdentifier` and `accessibilityTraits`.

![Accessibility](docs/screenshots/06_accessibility.png)

---

### Spacing annotations
Blue dashed lines with **centered numeric labels** show distances from the selected view to its superview edges. Labels feature dark semi-transparent backgrounds with colored borders for legibility on any background.

![Spacing](docs/screenshots/07_spacing.png)

---

## Visual Indicators

The inspector overlay uses a consistent color language to communicate different types of information at a glance:

| Color | Meaning |
|-------|---------|
| 🔵 **Blue** | Spacing annotations — dashed lines with numeric labels showing the distance from the selected view's edges to its superview's edges |
| 🔴 **Red** | Info panel — the scrollable property panel at the bottom of the screen uses a red-tinted background and red shadow to clearly identify it as the inspector UI, distinct from the inspected content |
| 🔵 **Blue (semi-transparent fill)** | Highlight overlay drawn over the currently selected view's frame |

These colors can be customized via `InspectorConfiguration` (`highlightColor`, `annotationColor`).

## Panel Interactions

When a view is selected, the info panel provides additional interaction feedback:

- **Haptic feedback** — Light impact feedback confirms view selection
- **Swipe to dismiss** — Swipe up on the panel to close it and clear highlights
- **Dimming overlay** — Background darkens slightly when panel is visible for better focus
- **Close button (×)** — Tap the panel's close button or the overlay's top-right button to exit

## Example App

A fully working example project is included in the repository:

```
Examples/DesignInspectorExample/
└── DesignInspectorExample/
    └── DesignInspectorExample.xcodeproj
```

The example app includes dedicated screens for:

- **UILabel & UIButton** — text, font, color, corner radius
- **UIImageView** — image name (SF Symbol + asset catalog), size, content mode
- **UIStackView** — axis, distribution, alignment, spacing
- **UIScrollView** — content size, insets, paging
- **Controls** — UISwitch, UISlider, UIProgressView, UIActivityIndicatorView
- **Accessibility** — identifiers, labels, traits
- **UISearchBar** — placeholder, style, cancel button, tint color

See [`Examples/DesignInspectorExample/README.md`](Examples/DesignInspectorExample/README.md) for step-by-step instructions to open and run it.

## Project Structure

```
Sources/
└── DesignInspectorKit/
    ├── DesignInspectorKit.swift                   # Main entry point (DesignInspector class)
    ├── Core/
    │   ├── DesignInspectorSwizzler.swift          # Method swizzling for auto-attach
    │   └── ViewHierarchyInspector.swift           # View hierarchy traversal & data extraction
    ├── Models/
    │   ├── ViewInspectorInfo.swift                # Inspected view data snapshot
    │   └── InspectorConfiguration.swift           # Appearance & token resolver options
    ├── Views/
    │   ├── InspectorOverlayViewController.swift   # Full-screen inspection overlay
    │   └── InspectorInfoPanelView.swift           # Scrollable property panel
    ├── Extensions/
    │   ├── UIView+Inspector.swift                 # Sibling spacing & deep hit-test helpers
    │   ├── UIViewController+Inspector.swift       # Gesture attach/detach helpers
    │   ├── UIColor+Hex.swift                      # Hex string conversion & brightness check
    │   └── String+Localization.swift              # Typed localization keys (InspectorKey)
    └── Resources/
        ├── en.lproj/Localizable.strings
        ├── pt-BR.lproj/Localizable.strings
        └── es.lproj/Localizable.strings
Tests/
└── DesignInspectorKitTests/
    └── DesignInspectorKitTests.swift              # Unit tests (30 test cases)
```

## Localization

DesignInspectorKit supports the following languages out of the box:

| Language | Code |
|----------|------|
| English | `en` |
| Portuguese (Brazil) | `pt-BR` |
| Spanish | `es` |

Use `InspectorKey` for typed access to all localized strings:

```swift
let title = InspectorKey.title
let closeLabel = InspectorKey.close
```

## Development

### Build

```bash
xcodebuild -scheme DesignInspectorKit -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Test

```bash
xcodebuild test -scheme DesignInspectorKit -destination 'platform=iOS Simulator,name=iPhone 16'
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
