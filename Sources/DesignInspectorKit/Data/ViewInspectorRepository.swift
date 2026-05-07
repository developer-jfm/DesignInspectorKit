import UIKit

/// Concrete implementation of `InspectorRepository`.
/// Delegates to `ViewHierarchyInspector` and `UIView` traversal extensions.
///
/// Equivalent to `ViewInspectorRepository` in DesignInspectorKit (Android).
final class ViewInspectorRepository: InspectorRepository {

    func findView(in root: UIView, navigationBar: UINavigationBar?, atWindowPoint point: CGPoint, overlayView: UIView) -> UIView? {
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

    func frame(of view: UIView, in coordinateSpace: UIView) -> CGRect {
        return view.convert(view.bounds, to: coordinateSpace)
    }

    private var cachedInspector: ViewHierarchyInspector?
    private var cachedConfiguration: InspectorConfiguration?

    func inspect(_ view: UIView, configuration: InspectorConfiguration) -> ViewInspectorInfo {
        if cachedInspector == nil || cachedConfiguration?.highlightColor != configuration.highlightColor {
            cachedInspector = ViewHierarchyInspector(configuration: configuration)
            cachedConfiguration = configuration
        }
        return cachedInspector!.inspectSingle(view)
    }
}
