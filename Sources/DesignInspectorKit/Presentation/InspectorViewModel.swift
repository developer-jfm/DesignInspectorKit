import Combine
import UIKit

/// Manages the inspector UI state following the MVVM pattern.
///
/// The View (`InspectorOverlayViewController`) observes `$state` and reacts to changes.
/// All business decisions (which view was hit, what info to show) happen here.
/// Receives UIKit types as parameters but never manipulates frames, layers, or view hierarchy.
///
/// Equivalent to `InspectorViewModel` in DesignInspectorKit (Android).
public final class InspectorViewModel {

    // MARK: - State

    /// The current inspector state. Observe via `$state` to react to selection and activation changes.
    @Published public private(set) var state: InspectorState = .idle

    // MARK: - Dependencies

    /// The configuration used for this inspector session — colors, resolvers, and overlay appearance.
    public let configuration: InspectorConfiguration
    private let repository: InspectorRepository

    // MARK: - Init

    /// Creates a view model with the given configuration and optional custom repository.
    /// - Parameters:
    ///   - configuration: Appearance and token resolver settings.
    ///   - repository: The data layer used to traverse and inspect views. Defaults to `ViewInspectorRepository`.
    public init(
        configuration: InspectorConfiguration,
        repository: InspectorRepository = ViewInspectorRepository()
    ) {
        self.configuration = configuration
        self.repository = repository
    }

    // MARK: - Intents

    /// `true` when the inspector is in `.active` or `.selected` state.
    public var isActive: Bool {
        if case .idle = state { return false }
        return true
    }

    /// Transitions state from `.idle` to `.active`. No-op if already active.
    public func activate() {
        guard case .idle = state else { return }
        state = .active
    }

    /// Transitions state back to `.idle` from any state.
    public func deactivate() {
        state = .idle
    }

    /// Called when the user taps at `windowPoint` within the overlay.
    /// `overlayView` is used as the coordinate space for frame conversion.
    public func onTap(in root: UIView, navigationBar: UINavigationBar? = nil, at windowPoint: CGPoint, overlayView: UIView) {
        guard let view = repository.findView(
            in: root,
            navigationBar: navigationBar,
            atWindowPoint: windowPoint,
            overlayView: overlayView
        ) else { return }

        let frameInOverlay = repository.frame(of: view, in: overlayView)
        let superviewFrame = view.superview.map { repository.frame(of: $0, in: overlayView) }
        let info = repository.inspect(view, configuration: configuration)

        state = .selected(InspectorSelection(
            frameInOverlay: frameInOverlay,
            superviewFrameInOverlay: superviewFrame,
            info: info
        ))
    }

    /// Clears the current selection, returning from `.selected` back to `.active`.
    public func clearSelection() {
        guard case .selected = state else { return }
        state = .active
    }
}
