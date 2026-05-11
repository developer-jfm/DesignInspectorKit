# DesignInspectorExample

An example iOS app demonstrating all features of **DesignInspectorKit**.

## Requirements

- Xcode 16+
- iOS 13.0+ simulator or device

## Running the Example

### Step 1 — Open the project

```bash
open Examples/DesignInspectorExample/DesignInspectorExample/DesignInspectorExample.xcodeproj
```

Or navigate in Finder to:
```
DesignInspector/
└── Examples/
    └── DesignInspectorExample/
        └── DesignInspectorExample/
            └── DesignInspectorExample.xcodeproj  ← open this
```

### Step 2 — Add the local package

1. In Xcode, go to **File → Add Package Dependencies...**
2. Click **Add Local...** in the bottom-left corner
3. Navigate to the repository root (`DesignInspector/`) and click **Add Package**
4. Make sure **DesignInspectorKit** is checked for the `DesignInspectorExample` target
5. Click **Add Package**

### Step 3 — Select a simulator

In the Xcode toolbar, select any iPhone simulator (e.g. **iPhone 16**).

### Step 4 — Run

Press **⌘R** or click the **▶ Run** button.

---

## How to Use the Inspector

Once the app is running:

1. Navigate to any example screen from the list
2. **Tap with 2 fingers** anywhere on the screen to activate the inspector overlay
3. **Tap any view** to see its properties in the panel at the bottom
4. **Scroll the panel** up to see all properties
5. **Tap the close button (✕)** to exit the inspector

> **Simulator tip:** Hold **Option ⌥** while clicking to simulate two simultaneous touches.

---

## Screens

| Screen | Demonstrates |
|--------|-------------|
| **UILabel & UIButton** | Text, font, color, cornerRadius, borderWidth, contentInsets, accessibility |
| **UIImageView** | Image name, intrinsic size, rendered size, contentMode |
| **UIStackView** | Axis, distribution, alignment, spacing |
| **UIScrollView** | contentSize, contentInset, paging |
| **Controls** | UISwitch (on/off, tint), UISlider (value, range), UIProgressView (progress, tint), UIActivityIndicatorView |
| **Accessibility** | accessibilityIdentifier, accessibilityLabel, accessibilityTraits |
| **UISearchBar** | Placeholder, text, style (default / minimal), cancel button, bar tint color |
| **UITextView** | Text, font, color, alignment — basic, styled and editable variants |
| **More Controls** | UISegmentedControl (segments, titles, selected index), UIPageControl (pages, current, tint colors), UIStepper (value, range, step), UIDatePicker (date, mode, min/max) |

---

## Adding DesignInspectorKit to Your Own Project

```swift
// AppDelegate.swift
import DesignInspectorKit

DesignInspector.shared.enable()
```

That's it — every view controller in your app will respond to a two-finger tap.
