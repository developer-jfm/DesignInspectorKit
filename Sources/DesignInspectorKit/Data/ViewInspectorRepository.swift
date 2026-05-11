import UIKit

/// Concrete implementation of `InspectorRepository`.
/// Delegates to `ViewHierarchyInspector` and `UIView` traversal extensions.
///
/// Equivalent to `ViewInspectorRepository` in DesignInspectorKit (Android).
public final class ViewInspectorRepository: InspectorRepository {

    public init() {}

    private var inspector: ViewHierarchyInspector?
    private var configurationToken: UUID?

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
                if let found = navBar.deepestView(at: p) { return found }
            }
            let localPoint = root.convert(point, from: root.window)
            return root.deepestView(at: localPoint)
        }
    }

    public func frame(of view: UIView, in coordinateSpace: UIView) -> CGRect {
        return view.convert(view.bounds, to: coordinateSpace)
    }

    public func inspect(_ view: UIView, configuration: InspectorConfiguration) -> ViewInspectorInfo {
        if configurationToken != configuration.token || inspector == nil {
            inspector = ViewHierarchyInspector(configuration: configuration)
            configurationToken = configuration.token
        }
        return inspector!.inspectSingle(view)
    }
}
