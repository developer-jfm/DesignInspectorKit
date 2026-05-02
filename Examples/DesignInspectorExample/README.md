# DesignInspectorExample

An example iOS app demonstrating all features of **DesignInspectorKit**.

## Setup

1. Open `DesignInspectorExample.xcodeproj` in Xcode
2. The project references `DesignInspectorKit` as a local Swift Package (two levels up: `../../`)
3. Select an iPhone simulator and run

## How to inspect

Once the app is running on simulator or device:

1. Navigate to any example screen
2. **Long press (2 seconds)** anywhere on the screen
3. **Tap any view** to inspect its properties
4. Swipe the panel up to see more properties
5. Tap **✕** to close the inspector

## Screens

| Screen | Demonstrates |
|--------|-------------|
| **UILabel & UIButton** | Text, font, color, cornerRadius, borderWidth, accessibility |
| **UIImageView** | Image name, intrinsic size, rendered size, contentMode |
| **UIStackView** | Axis, distribution, alignment, spacing |
| **UIScrollView** | contentSize, contentInset, paging |
| **Controls** | UISwitch, UISlider, UIProgressView, UIActivityIndicatorView |
| **Accessibility** | accessibilityIdentifier, accessibilityLabel, traits |

## Adding to an existing project

```swift
import DesignInspectorKit

// In AppDelegate or app entry point:
DesignInspector.shared.enable()
```
