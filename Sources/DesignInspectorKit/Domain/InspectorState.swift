import CoreGraphics

/// Represents the UI state of the inspector overlay.
/// Used as the single source of truth in `InspectorViewModel`.
///
/// Equivalent to `InspectorState` in DesignInspectorKit (Android).
public enum InspectorState: Equatable {

    /// Inspector is not active — overlay is not presented.
    case idle

    /// Inspector is active, waiting for the user to tap a view.
    case active

    /// A view has been tapped and its info is ready to display.
    case selected(InspectorSelection)
}

/// The data associated with a selected view.
public struct InspectorSelection: Equatable {
    /// The frame of the selected view in the overlay's coordinate space.
    public let frameInOverlay: CGRect
    /// The frame of the selected view's superview in the overlay's coordinate space. `nil` if no superview.
    public let superviewFrameInOverlay: CGRect?
    /// The inspected properties of the selected view.
    public let info: ViewInspectorInfo

    public static func == (lhs: InspectorSelection, rhs: InspectorSelection) -> Bool {
        lhs.frameInOverlay == rhs.frameInOverlay &&
        lhs.superviewFrameInOverlay == rhs.superviewFrameInOverlay &&
        lhs.info.className == rhs.info.className
    }
}
