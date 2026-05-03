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
    .package(url: "https://github.com/developer-jfm/DesignInspectorKit.git", from: "1.0.0")
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
config.colorTokenColorResolver = { color in
    return DesignTokens.name(for: color)
}
config.fontTokenColorResolver = { font in
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
| **Accessibility** | Identifier, Label, Traits, Is accessibility element |
| **Sibling Spacing** | Distance to nearest sibling above, below, left, right |
| **Hierarchy** | Depth level, Subviews count |

## Example App

A fully working example project is included in the repository:

```
Examples/DesignInspectorExample/
└── DesignInspectorExample/
    └── DesignInspectorExample.xcodeproj
```

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
    └── DesignInspectorKitTests.swift              # Unit tests (20 test cases)
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

### Lint

```bash
swiftlint
```

## Git Flow

This project follows **Git Flow**:

- `main` — stable releases
- `develop` — integration branch
- `feature/*` — new features
- `hotfix/*` — production fixes
- `release/*` — release preparation

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request targeting `develop`

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
