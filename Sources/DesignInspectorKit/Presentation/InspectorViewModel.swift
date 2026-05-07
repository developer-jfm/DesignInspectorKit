import Combine
import UIKit

/// Manages the inspector UI state following the MVVM pattern.
///
/// The View (`InspectorOverlayViewController`) observes `$state` and reacts to changes.
/// All business decisions (which view was hit, what info to show) happen here.
/// Contains zero UIKit view manipulation — only pure state transitions.
///
/// Equivalent to `InspectorViewModel` in DesignInspectorKit (Android).
public final class InspectorViewModel {

    // MARK: - State

    @Published public private(set) var state: InspectorState = .idle

    // MARK: - Dependencies

    public let configuration: InspectorConfiguration
    private let repository: InspectorRepository

    // MARK: - Init

    public init(
        configuration: InspectorConfiguration,
        repository: InspectorRepository = ViewInspectorRepository()
    ) {
        self.configuration = configuration
        self.repository = repository
    }

    // MARK: - Intents

    public var isActive: Bool {
        if case .idle = state { return false }
        return true
    }

    public func activate() {
        guard case .idle = state else { return }
        state = .active
    }

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

    public func clearSelection() {
        guard case .selected = state else { return }
        state = .active
    }
}
