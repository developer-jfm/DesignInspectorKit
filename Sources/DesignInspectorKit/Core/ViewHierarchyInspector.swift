//
//  File.swift
//  DesignInspectorKit
//
//

import UIKit

private extension NSDirectionalEdgeInsets {
    var edgeInsets: UIEdgeInsets {
        UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
    }
}

/// Traverses the view hierarchy and extracts all inspectable properties from each view.
///
/// Use `inspect(_:)` to get a flat list of all views in the hierarchy,
/// or `inspectSingle(_:)` to inspect a single view.
public final class ViewHierarchyInspector {
    private let configuration: InspectorConfiguration
    
    /// Creates an inspector with the given configuration.
    /// - Parameter configuration: Defines appearance and token resolvers used during extraction.
    public init(configuration: InspectorConfiguration) {
        self.configuration = configuration
    }
    
    /// Recursively inspects a view and all of its subviews.
    /// - Parameter view: The root view to inspect.
    /// - Returns: A flat array of `ViewInspectorInfo`, ordered depth-first.
    public func inspect(_ view: UIView) -> [ViewInspectorInfo] {
        return inspectRecursively(view, depth: 0)
    }
    
    /// Inspects a single view without traversing its subviews.
    /// - Parameter view: The view to inspect.
    /// - Returns: A `ViewInspectorInfo` snapshot of the view.
    public func inspectSingle(_ view: UIView) -> ViewInspectorInfo {
        return extractInfo(view, depth: 0)
    }
    
    private func inspectRecursively(_ view: UIView, depth: Int) -> [ViewInspectorInfo] {
        var results: [ViewInspectorInfo] = []
        let info = extractInfo(view, depth: depth)
        results.append(info)
        for subview in view.subviews {
            results.append(contentsOf: inspectRecursively(subview, depth: depth + 1))
        }
        return results
    }
    
    private func extractInfo(_ view: UIView, depth: Int) -> ViewInspectorInfo {
        let textProps = extractTextProperties(from: view)
        let imageProps = extractImageProperties(from: view)
        let layoutProps = extractLayoutProperties(from: view)
        let controlProps = extractControlState(from: view)
        let searchBarProps = extractSearchBarProperties(from: view)
        let borderColor = extractBorderColor(from: view)
        
        let accessibilityLabel = imageProps.accessibilityLabel ?? view.accessibilityLabel
        
        let backgroundColorToken = view.backgroundColor.flatMap { configuration.colorTokenResolver?($0) }
        let textColorToken = textProps.textColor.flatMap { configuration.colorTokenResolver?($0) }
        let fontToken = textProps.font.flatMap { configuration.fontTokenResolver?($0) }
        let spacingToken = layoutProps.spacing.flatMap { configuration.stackSpacingTokenResolver?($0) }
        let frameInWindow = view.superview?.convert(view.frame, to: nil) ?? view.frame
        
        return ViewInspectorInfo(
            className: String(describing: type(of: view)),
            frame: view.frame,
            frameInWindow: frameInWindow,
            depth: depth,
            backgroundColor: view.backgroundColor,
            backgroundColorToken: backgroundColorToken,
            tintColor: view.tintColor,
            cornerRadius: view.layer.cornerRadius,
            borderWidth: view.layer.borderWidth,
            borderColor: borderColor,
            alpha: view.alpha,
            imageName: imageProps.name,
            imageNameToken: imageProps.token,
            imageSize: imageProps.size,
            imageRenderedSize: imageProps.renderedSize,
            contentMode: imageProps.contentMode,
            text: textProps.text,
            font: textProps.font,
            fontToken: fontToken,
            textColor: textProps.textColor,
            textColorToken: textColorToken,
            textAlignment: textProps.textAlignment,
            numberOfLines: textProps.numberOfLines,
            spacing: layoutProps.spacing,
            spacingToken: spacingToken,
            stackAxis: layoutProps.stackAxis,
            stackDistribution: layoutProps.stackDistribution,
            stackAlignment: layoutProps.stackAlignment,
            contentInsets: layoutProps.contentInsets,
            scrollContentSize: layoutProps.scrollContentSize,
            scrollIsPagingEnabled: layoutProps.scrollIsPagingEnabled,
            layoutMargin: view.layoutMargins,
            constraints: {
                let own = view.constraints
                let fromSuperview = (view.superview?.constraints ?? []).filter {
                    ($0.firstItem as? UIView) === view || ($0.secondItem as? UIView) === view
                }
                return (own + fromSuperview).map { constraint in
                    ConstraintInfo(
                        attribute: attributeName(constraint.firstAttribute),
                        relation: relationName(constraint.relation),
                        constant: constraint.constant,
                        multiplier: constraint.multiplier,
                        priority: constraint.priority.rawValue,
                        isActive: constraint.isActive
                    )
                }
            }(),
            accessibilityIdentifier: view.accessibilityIdentifier,
            accessibilityLabel: accessibilityLabel,
            accessibilityTraits: view.accessibilityTraits,
            isAccessibilityElement: view.isAccessibilityElement,
            switchIsOn: controlProps.switchIsOn,
            switchOnTintColor: controlProps.switchOnTintColor,
            switchThumbTintColor: controlProps.switchThumbTintColor,
            sliderMinValue: controlProps.sliderMinValue,
            sliderMaxValue: controlProps.sliderMaxValue,
            sliderValue: controlProps.sliderValue,
            progressValue: controlProps.progressValue,
            progressTintColor: controlProps.progressTintColor,
            activityIsAnimating: controlProps.activityIsAnimating,
            segmentedSelectedIndex: controlProps.segmentedSelectedIndex,
            segmentedNumberOfSegments: controlProps.segmentedNumberOfSegments,
            segmentedSegmentTitles: controlProps.segmentedSegmentTitles,
            pageControlCurrentPage: controlProps.pageControlCurrentPage,
            pageControlNumberOfPages: controlProps.pageControlNumberOfPages,
            pageControlPageIndicatorTintColor: controlProps.pageControlPageIndicatorTintColor,
            pageControlCurrentPageIndicatorTintColor: controlProps.pageControlCurrentPageIndicatorTintColor,
            stepperValue: controlProps.stepperValue,
            stepperMinimumValue: controlProps.stepperMinimumValue,
            stepperMaximumValue: controlProps.stepperMaximumValue,
            stepperStepValue: controlProps.stepperStepValue,
            datePickerDate: controlProps.datePickerDate,
            datePickerMode: controlProps.datePickerMode,
            datePickerMinimumDate: controlProps.datePickerMinimumDate,
            datePickerMaximumDate: controlProps.datePickerMaximumDate,
            searchBarPlaceholder: searchBarProps.placeholder,
            searchBarText: searchBarProps.text,
            searchBarStyle: searchBarProps.style,
            searchBarShowsCancelButton: searchBarProps.showsCancelButton,
            searchBarTintColor: searchBarProps.barTintColor,
            siblingSpacingAbove: view.spacingToSiblingAbove,
            siblingSpacingBelow: view.spacingToSiblingBelow,
            siblingSpacingLeft: view.spacingToSiblingLeft,
            siblingSpacingRight: view.spacingToSiblingRight,
            subviewsCount: view.subviews.count)
    }
    
    private struct TextProperties {
        var text: String?
        var font: UIFont?
        var textColor: UIColor?
        var textAlignment: NSTextAlignment?
        var numberOfLines: Int?
    }
    
    private func extractTextProperties(from view: UIView) -> TextProperties {
        var props = TextProperties()
        
        if let label = view as? UILabel {
            props.text = label.text
            props.font = label.font
            props.textColor = label.textColor
            props.textAlignment = label.textAlignment
            props.numberOfLines = label.numberOfLines
        } else if let button = view as? UIButton {
            props.text = button.title(for: .normal)
            props.font = button.titleLabel?.font
            props.textColor = button.titleColor(for: .normal)
            props.textAlignment = button.titleLabel?.textAlignment
            props.numberOfLines = button.titleLabel?.numberOfLines
        } else if let textField = view as? UITextField {
            props.text = textField.text?.nilIfEmpty ?? textField.placeholder
            props.font = textField.font
            props.textColor = textField.textColor
            props.textAlignment = textField.textAlignment
            props.numberOfLines = 1
        } else if let textView = view as? UITextView {
            props.text = textView.text
            props.font = textView.font
            props.textColor = textView.textColor
            props.textAlignment = textView.textAlignment
            props.numberOfLines = textView.textContainer.maximumNumberOfLines
        }
        return props
    }
    
    private struct ImageProperties {
        var name: String?
        var token: String?
        var size: CGSize?
        var renderedSize: CGSize?
        var contentMode: UIView.ContentMode?
        var accessibilityLabel: String?
    }
    
    private func extractImageProperties(from view: UIView) -> ImageProperties {
        var props = ImageProperties()
        
        guard let imageView = view as? UIImageView else {
            return props
        }
        
        props.contentMode = imageView.contentMode
        props.renderedSize = imageView.bounds.size
        
        guard let image = imageView.image else {
            return props
        }
        
        props.size = CGSize(width: image.size.width, height: image.size.height)
        props.token = configuration.imageTokenResolver?(image)
        props.accessibilityLabel = configuration.imageAccessibilityLabelResolver?(image) ?? imageView.accessibilityLabel?.nilIfEmpty
        
        props.name = props.token
        ?? imageView.accessibilityIdentifier?.nilIfEmpty
        ?? image.accessibilityIdentifier?.nilIfEmpty
        ?? imageName(from: image)
        ?? describeImage(image)

        return props
    }

    /// Attempts to recover the original asset name of a `UIImage`.
    /// Parses the image's `description` string which contains the asset/symbol name at runtime.
    private func imageName(from image: UIImage) -> String? {
        let desc = image.description
        // SF Symbol format: "symbol(system: checkmark.seal.fill)"
        if let range = desc.range(of: "symbol\\(system: ([^)]+)\\)", options: .regularExpression) {
            let match = String(desc[range])
            let name = match
                .replacingOccurrences(of: "symbol(system: ", with: "")
                .replacingOccurrences(of: ")", with: "")
                .trimmingCharacters(in: .whitespaces)
            if !name.isEmpty { return name }
        }
        // Asset catalog format: "named(system: MyImage)" or "named: MyImage"
        if let range = desc.range(of: "named\\(?[^:]*: ([^,>)]+)", options: .regularExpression) {
            let match = String(desc[range])
            if let colonRange = match.range(of: ": ") {
                let name = String(match[colonRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                if !name.isEmpty { return name }
            }
        }
        return image.imageAsset.flatMap { asset in
            (asset.value(forKey: "assetName") as? String)?.nilIfEmpty
        }
    }

    private struct SearchBarProperties {
        var placeholder: String?
        var text: String?
        var style: UISearchBar.Style?
        var showsCancelButton: Bool?
        var barTintColor: UIColor?
    }

    private func extractSearchBarProperties(from view: UIView) -> SearchBarProperties {
        var props = SearchBarProperties()
        guard let searchBar = view as? UISearchBar else { return props }
        props.placeholder = searchBar.placeholder?.nilIfEmpty
        props.text = searchBar.text?.nilIfEmpty
        props.style = searchBar.searchBarStyle
        props.showsCancelButton = searchBar.showsCancelButton
        props.barTintColor = searchBar.barTintColor
        return props
    }

    private func describeImage(_ image: UIImage) -> String {
        let scale = image.scale
        return "Image(\(Int(image.size.width))x\(Int(image.size.height))@\(scale)x)"
    }
    
    private struct LayoutProperties {
        var spacing: CGFloat?
        var stackAxis: NSLayoutConstraint.Axis?
        var stackDistribution: UIStackView.Distribution?
        var stackAlignment: UIStackView.Alignment?
        var contentInsets: UIEdgeInsets?
        var scrollContentSize: CGSize?
        var scrollIsPagingEnabled: Bool?
    }
    
    private func extractLayoutProperties(from view: UIView) -> LayoutProperties {
        var props = LayoutProperties()
        
        if let stackView = view as? UIStackView {
            props.spacing = stackView.spacing
            props.stackAxis = stackView.axis
            props.stackDistribution = stackView.distribution
            props.stackAlignment = stackView.alignment
        }
        
        if let scrollView = view as? UIScrollView {
            props.contentInsets = scrollView.contentInset
            props.scrollContentSize = scrollView.contentSize
            props.scrollIsPagingEnabled = scrollView.isPagingEnabled
        } else if let button = view as? UIButton {
            if #available(iOS 15.0, *) {
                props.contentInsets = button.configuration?.contentInsets.edgeInsets
            } else {
                props.contentInsets = button.contentEdgeInsets
            }
        }
        
        return props
    }
    
    private struct ControlState {
        var switchIsOn: Bool?
        var switchOnTintColor: UIColor?
        var switchThumbTintColor: UIColor?
        var sliderMinValue: Float?
        var sliderMaxValue: Float?
        var sliderValue: Float?
        var progressValue: Float?
        var progressTintColor: UIColor?
        var activityIsAnimating: Bool?
        var segmentedSelectedIndex: Int?
        var segmentedNumberOfSegments: Int?
        var segmentedSegmentTitles: [String]?
        var pageControlCurrentPage: Int?
        var pageControlNumberOfPages: Int?
        var pageControlPageIndicatorTintColor: UIColor?
        var pageControlCurrentPageIndicatorTintColor: UIColor?
        var stepperValue: Double?
        var stepperMinimumValue: Double?
        var stepperMaximumValue: Double?
        var stepperStepValue: Double?
        var datePickerDate: Date?
        var datePickerMode: UIDatePicker.Mode?
        var datePickerMinimumDate: Date?
        var datePickerMaximumDate: Date?
    }
    
    private func extractControlState(from view: UIView) -> ControlState {
        var props = ControlState()
        
        if let sw = view as? UISwitch {
            props.switchIsOn = sw.isOn
            props.switchOnTintColor = sw.onTintColor
            props.switchThumbTintColor = sw.thumbTintColor
        } else if let slider = view as? UISlider {
            props.sliderMinValue = slider.minimumValue
            props.sliderMaxValue = slider.maximumValue
            props.sliderValue = slider.value
        } else if let progress = view as? UIProgressView {
            props.progressValue = progress.progress
            props.progressTintColor = progress.progressTintColor
        } else if let activity = view as? UIActivityIndicatorView {
            props.activityIsAnimating = activity.isAnimating
        } else if let segmented = view as? UISegmentedControl {
            props.segmentedSelectedIndex = segmented.selectedSegmentIndex == UISegmentedControl.noSegment ? nil : segmented.selectedSegmentIndex
            props.segmentedNumberOfSegments = segmented.numberOfSegments
            props.segmentedSegmentTitles = (0..<segmented.numberOfSegments).compactMap { segmented.titleForSegment(at: $0) }
        } else if let pageControl = view as? UIPageControl {
            props.pageControlCurrentPage = pageControl.currentPage
            props.pageControlNumberOfPages = pageControl.numberOfPages
            props.pageControlPageIndicatorTintColor = pageControl.pageIndicatorTintColor
            props.pageControlCurrentPageIndicatorTintColor = pageControl.currentPageIndicatorTintColor
        } else if let stepper = view as? UIStepper {
            props.stepperValue = stepper.value
            props.stepperMinimumValue = stepper.minimumValue
            props.stepperMaximumValue = stepper.maximumValue
            props.stepperStepValue = stepper.stepValue
        } else if let datePicker = view as? UIDatePicker {
            props.datePickerDate = datePicker.date
            props.datePickerMode = datePicker.datePickerMode
            props.datePickerMinimumDate = datePicker.minimumDate
            props.datePickerMaximumDate = datePicker.maximumDate
        }
        
        return props
    }
    
    private func extractBorderColor(from view: UIView) -> UIColor? {
        guard let cgColor = view.layer.borderColor else {
            return nil
        }
        return UIColor(cgColor: cgColor)
    }
    
    private func attributeName(_ attribute: NSLayoutConstraint.Attribute) -> String {
        switch attribute {
        case .left: return "left"
        case .right: return "right"
        case .top: return "top"
        case .bottom: return "bottom"
        case .leading: return "leading"
        case .trailing: return "trailing"
        case .width: return "width"
        case .height: return "height"
        case .centerX: return "centerX"
        case .centerY: return "centerY"
        case .lastBaseline: return "lastBaseline"
        case .firstBaseline: return "firstBaseline"
        case .leftMargin: return "leftMargin"
        case .rightMargin: return "rightMargin"
        case .topMargin: return "topMargin"
        case .bottomMargin: return "bottomMargin"
        case .leadingMargin: return "leadingMargin"
        case .trailingMargin: return "trailingMargin"
        case .centerXWithinMargins: return "centerXWithinMargins"
        case .centerYWithinMargins: return "centerYWithinMargins"
        case .notAnAttribute: return "notAnAttribute"
        @unknown default: return "unknown"
        }
    }
    
    private func relationName(_ relation: NSLayoutConstraint.Relation) -> String {
        switch relation {
        case .lessThanOrEqual: return "<="
        case .equal: return "=="
        case .greaterThanOrEqual: return ">="
        @unknown default: return "?"
        }
    }
    
}

private extension String {
    /// Returns `nil` if the string is empty, otherwise returns `self`.
    var nilIfEmpty: String? {
        self.isEmpty ? nil : self
    }
}
