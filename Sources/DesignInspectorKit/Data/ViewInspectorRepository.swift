import UIKit

/// Concrete implementation of `InspectorRepository`.
/// Delegates to `ViewHierarchyInspector` and `UIView` traversal extensions.
///
/// Equivalent to `ViewInspectorRepository` in DesignInspectorKit (Android).
public final class ViewInspectorRepository: InspectorRepository {

    /// Creates a new repository instance.
    public init() {}

    private var inspector: ViewHierarchyInspector?
    private var configurationToken: UUID?

    /// Returns the deepest inspectable view at `point` (window-space) within `root`, checking `navigationBar` first.
    public func findView(in root: UIView, navigationBar: UINavigationBar?, atWindowPoint point: CGPoint, overlayView: UIView) -> UIView? {
        if #available(iOS 19.0, *) {
            if let navBar = navigationBar,
               let found = navBar.deepestInspectableView(atWindowPoint: point) {
                return found
            }
            return root.deepestInspectableView(atWindowPoint: point)
        } else {
            if let navBar = navigationBar {
                let p = overlayView.convert(point, to: navBar)
                if let found = navBar.deepestInspectableView(atWindowPoint: point) { return found }
                if let found = navBar.deepestView(at: p) { return found }
            }
            if let found = root.deepestInspectableView(atWindowPoint: point) { return found }
            let localPoint = overlayView.convert(point, to: root)
            return root.deepestView(at: localPoint)
        }
    }

    /// Returns the frame of `view` converted to `coordinateSpace`.
    public func frame(of view: UIView, in coordinateSpace: UIView) -> CGRect {
        return view.convert(view.bounds, to: coordinateSpace)
    }

    /// Extracts all inspectable properties from `view`, recreating the inspector if the configuration changed.
    public func inspect(_ view: UIView, configuration: InspectorConfiguration) -> ViewInspectorInfo {
        if configurationToken != configuration.token || inspector == nil {
            inspector = ViewHierarchyInspector(configuration: configuration)
            configurationToken = configuration.token
        }
        return inspector!.inspectSingle(view)
    }
}
