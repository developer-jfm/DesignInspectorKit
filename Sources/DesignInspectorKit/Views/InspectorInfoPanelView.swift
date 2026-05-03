//
//  File.swift
//  DesignInspectorKit
//
//

import UIKit

/// A scrollable panel that displays all inspectable properties of a selected view.
/// Populated by calling `configure(with:)` after a view is selected in the overlay.
final class InspectorInfoPanelView: UIView {
    
    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 8
        static let labelWidth: CGFloat = 100
        static let swatchSize: CGFloat = 16
        /// Inset between the panel's own background and the containerView, making the background visible.
        static let panelInset: CGFloat = 6
        static let closeBtnSize: CGFloat = 28
    }
    
    private let configuration: InspectorConfiguration

    /// Called when the user taps the close button on the panel.
    var onClose: (() -> Void)?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = configuration.panelBackgroundColor
        view.layer.cornerRadius = Layout.cornerRadius
        view.layer.shadowColor = configuration.annotationColor.cgColor
        view.layer.shadowOpacity = 0.6
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var closePanelButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark.circle.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = configuration.annotationColor
        button.accessibilityLabel = InspectorKey.close
        button.accessibilityIdentifier = "inspector_panel_close_button"
        button.addTarget(self, action: #selector(closePanelTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = configuration.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Layout.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()
    
    /// Creates the panel with the given inspector configuration.
    /// - Parameter configuration: Used for colors and token resolvers.
    init(configuration: InspectorConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = configuration.annotationColor.withAlphaComponent(0.15)
        layer.cornerRadius = Layout.cornerRadius
        addSubview(scrollView)

        scrollView.addSubview(containerView)
        containerView.addSubview(closePanelButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            // scrollView fills the entire panel view
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // containerView is inset from the scroll edges, exposing the panel background
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Layout.panelInset),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: Layout.panelInset),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -Layout.panelInset),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Layout.panelInset),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -Layout.panelInset * 2),

            closePanelButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Layout.padding / 2),
            closePanelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.padding / 2),
            closePanelButton.widthAnchor.constraint(equalToConstant: Layout.closeBtnSize),
            closePanelButton.heightAnchor.constraint(equalToConstant: Layout.closeBtnSize),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Layout.padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.padding),
            titleLabel.trailingAnchor.constraint(equalTo: closePanelButton.leadingAnchor, constant: -Layout.spacing),

            contentStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.spacing),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.padding),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.padding),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Layout.padding),
        ])
    }
    
    @objc private func closePanelTapped() {
        onClose?()
    }

    /// Populates the panel with data from the given `ViewInspectorInfo`.
    /// Clears any previously displayed content before rendering.
    /// - Parameter info: The inspected view's property snapshot.
    func configure(with info: ViewInspectorInfo) {
        titleLabel.text = info.className
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        addInfoRow(
            label: InspectorKey.frame,
            value: "\(Int(info.frame.origin.x)), \(Int(info.frame.origin.y)) - \(Int(info.frame.width)) x \(Int(info.frame.height))"
        )
        if let bgColor = info.backgroundColor, bgColor != .clear {
            let colorValue: String
            if let token = info.backgroundColorToken {
                colorValue = "\(token) (\(bgColor.hexString))"
            } else {
                colorValue = bgColor.hexString
            }
            addInfoRow(label: InspectorKey.background, value: colorValue, color: bgColor)
        }

        if let imageName = info.imageName {
            addInfoRow(label: InspectorKey.image, value: imageName)
        }

        if let size = info.imageSize, size.width > 0 && size.height > 0 {
            addInfoRow(label: InspectorKey.imageSize, value: "\(Int(size.width)) x \(Int(size.height)) pt")
        }

        if let renderedSize = info.imageRenderedSize, renderedSize.width > 0 && renderedSize.height > 0 {
            addInfoRow(label: InspectorKey.imageRenderedSize, value: "\(Int(renderedSize.width)) x \(Int(renderedSize.height)) pt")
        }

        if let contentMode = info.contentMode {
            addInfoRow(label: InspectorKey.contentMode, value: contentModeName(contentMode))
        }

        if let text = info.text, !text.isEmpty {
            let truncated = text.count > 30 ? String(text.prefix(30)) + "..." : text
            addInfoRow(label: InspectorKey.text, value: "\"\(truncated)\"")
        }

        if let font = info.font {
            let fontValue: String
            if let token = info.fontToken {
                fontValue = "\(token) (\(font.fontName) \(Int(font.pointSize))pt)"
            } else {
                fontValue = "\(font.fontName) \(Int(font.pointSize))pt"
            }
            addInfoRow(label: InspectorKey.font, value: fontValue)
        }

        if let alignment = info.textAlignment {
            addInfoRow(label: InspectorKey.textAlignment, value: textAlignmentName(alignment))
        }

        if let lines = info.numberOfLines {
            addInfoRow(label: InspectorKey.numberOfLines, value: lines == 0 ? "∞" : "\(lines)")
        }

        if let textColor = info.textColor, textColor != .clear {
            let colorValue: String
            if let token = info.textColorToken {
                colorValue = "\(token) (\(textColor.hexString))"
            } else {
                colorValue = textColor.hexString
            }
            addInfoRow(label: InspectorKey.textColor, value: colorValue, color: textColor)
        }

        if let spacing = info.spacing {
            let spacingValue: String
            if let token = info.spacingToken {
                spacingValue = "\(token) (\(Int(spacing))pt)"
            } else {
                spacingValue = "\(Int(spacing))pt"
            }
            addInfoRow(label: InspectorKey.spacing, value: spacingValue)
        }

        if info.cornerRadius > 0 {
            addInfoRow(label: InspectorKey.cornerRadius, value: "\(Int(info.cornerRadius))pt")
        }

        if info.alpha < 1 {
            addInfoRow(label: InspectorKey.alpha, value: String(format: "%.2f", info.alpha))
        }

        if let accessibilityId = info.accessibilityIdentifier {
            addInfoRow(label: InspectorKey.accessibilityId, value: accessibilityId)
        }

        if let accessibilityLabel = info.accessibilityLabel, !accessibilityLabel.isEmpty {
            addInfoRow(label: InspectorKey.accessibilityLabel, value: accessibilityLabel)
        }

        if info.isAccessibilityElement {
            addInfoRow(label: InspectorKey.accessibilityTraits, value: accessibilityTraitsDescription(info.accessibilityTraits))
        }

        if info.borderWidth > 0 {
            addInfoRow(label: InspectorKey.borderWidth, value: "\(info.borderWidth)pt")
        }

        if info.borderWidth > 0, let borderColor = info.borderColor {
            addInfoRow(label: InspectorKey.borderColor, value: borderColor.hexString, color: borderColor)
        }

        if let tintColor = info.tintColor, info.isControl || info.isImageView {
            addInfoRow(label: InspectorKey.tintColor, value: tintColor.hexString, color: tintColor)
        }

        // MARK: UIStackView
        if let axis = info.stackAxis {
            addInfoRow(label: InspectorKey.stackAxis, value: axis == .horizontal ? "Horizontal" : "Vertical")
        }
        if let distribution = info.stackDistribution {
            addInfoRow(label: InspectorKey.stackDistribution, value: stackDistributionName(distribution))
        }
        if let alignment = info.stackAlignment {
            addInfoRow(label: InspectorKey.stackAlignment, value: stackAlignmentName(alignment))
        }

        // MARK: UIScrollView
        if let contentSize = info.scrollContentSize {
            addInfoRow(label: InspectorKey.scrollContentSize, value: "\(Int(contentSize.width)) x \(Int(contentSize.height)) pt")
        }
        if let paging = info.scrollIsPagingEnabled {
            addInfoRow(label: InspectorKey.scrollPaging, value: paging ? "Enabled" : "Disabled")
        }
        if let insets = info.contentInsets {
            addInfoRow(label: InspectorKey.contentInsets, value: "T:\(Int(insets.top)) L:\(Int(insets.left)) B:\(Int(insets.bottom)) R:\(Int(insets.right))")
        }

        // MARK: UISwitch
        if let isOn = info.switchIsOn {
            addInfoRow(label: InspectorKey.switchIsOn, value: isOn ? "true" : "false")
        }
        if let onTint = info.switchOnTintColor {
            addInfoRow(label: InspectorKey.switchOnTint, value: onTint.hexString, color: onTint)
        }
        if let thumbTint = info.switchThumbTintColor {
            addInfoRow(label: InspectorKey.switchThumbTint, value: thumbTint.hexString, color: thumbTint)
        }

        // MARK: UISlider
        if let sliderValue = info.sliderValue, let minVal = info.sliderMinValue, let maxVal = info.sliderMaxValue {
            addInfoRow(label: InspectorKey.sliderValue, value: String(format: "%.2f", sliderValue))
            addInfoRow(label: InspectorKey.sliderRange, value: "\(minVal) – \(maxVal)")
        }

        // MARK: UIProgressView
        if let progress = info.progressValue {
            addInfoRow(label: InspectorKey.progressValue, value: String(format: "%.0f%%", progress * 100))
        }
        if let progressTint = info.progressTintColor {
            addInfoRow(label: InspectorKey.progressTint, value: progressTint.hexString, color: progressTint)
        }

        // MARK: UIActivityIndicatorView
        if let animating = info.activityIsAnimating {
            addInfoRow(label: InspectorKey.activityAnimating, value: animating ? "true" : "false")
        }

        // MARK: Layout Margins
        let m = info.layoutMargin
        if m.top != 0 || m.left != 0 || m.bottom != 0 || m.right != 0 {
            addInfoRow(label: InspectorKey.layoutMargins, value: "T:\(Int(m.top)) L:\(Int(m.left)) B:\(Int(m.bottom)) R:\(Int(m.right))")
        }

        // MARK: Sibling Spacing
        if let view = info.view {
            if let topSpacing = view.spacingToSiblingAbove {
                let spacingValue = configuration.spacingTokenResolver.flatMap { $0(topSpacing) }
                    .map { "\($0) (\(Int(topSpacing))pt)" } ?? "\(Int(topSpacing))pt"
                addInfoRow(label: InspectorKey.spacingAbove, value: spacingValue)
            }
            if let bottomSpacing = view.spacingToSiblingBelow {
                let spacingValue = configuration.spacingTokenResolver.flatMap { $0(bottomSpacing) }
                    .map { "\($0) (\(Int(bottomSpacing))pt)" } ?? "\(Int(bottomSpacing))pt"
                addInfoRow(label: InspectorKey.spacingBelow, value: spacingValue)
            }
            if let leftSpacing = view.spacingToSiblingLeft {
                addInfoRow(label: InspectorKey.spacingLeft, value: "\(Int(leftSpacing))pt")
            }
            if let rightSpacing = view.spacingToSiblingRight {
                addInfoRow(label: InspectorKey.spacingRight, value: "\(Int(rightSpacing))pt")
            }
        }
    }
    
    /// Appends a labeled row to the content stack.
    /// Optionally renders a color swatch next to the label when `color` is provided.
    /// - Parameters:
    ///   - label: The property name displayed on the left.
    ///   - value: The property value displayed on the right.
    ///   - color: An optional color to render as a swatch.
    private func addInfoRow(label: String, value: String, color: UIColor? = nil) {
        let rowView = UIView()
        rowView.translatesAutoresizingMaskIntoConstraints = false
        
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        labelView.textColor = configuration.secondaryTextColor
        labelView.numberOfLines = 0
        labelView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        labelView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        labelView.translatesAutoresizingMaskIntoConstraints = false

        let valueView = UILabel()
        valueView.text = value
        valueView.translatesAutoresizingMaskIntoConstraints = false
        valueView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        valueView.textColor = configuration.textColor
        valueView.numberOfLines = 0
        valueView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        valueView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        rowView.addSubview(labelView)
        rowView.addSubview(valueView)
        
        if let color = color {
            let swatchView = UIView()
            swatchView.backgroundColor = color
            swatchView.layer.cornerRadius = 4
            swatchView.layer.borderWidth = 1
            swatchView.layer.borderColor = UIColor.lightGray.cgColor
            swatchView.translatesAutoresizingMaskIntoConstraints = false
            
            rowView.addSubview(swatchView)
            
            NSLayoutConstraint.activate([
                swatchView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
                swatchView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
                swatchView.widthAnchor.constraint(equalToConstant: Layout.swatchSize),
                swatchView.heightAnchor.constraint(equalToConstant: Layout.swatchSize),
                
                labelView.leadingAnchor.constraint(equalTo: swatchView.trailingAnchor, constant: Layout.spacing),
                labelView.topAnchor.constraint(equalTo: rowView.topAnchor),
                labelView.bottomAnchor.constraint(equalTo: rowView.bottomAnchor),
                labelView.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.labelWidth),

                valueView.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: Layout.spacing),
                valueView.topAnchor.constraint(equalTo: rowView.topAnchor),
                valueView.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
                valueView.bottomAnchor.constraint(equalTo: rowView.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                labelView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
                labelView.topAnchor.constraint(equalTo: rowView.topAnchor),
                labelView.bottomAnchor.constraint(equalTo: rowView.bottomAnchor),
                labelView.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.labelWidth),

                valueView.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: Layout.spacing),
                valueView.topAnchor.constraint(equalTo: rowView.topAnchor),
                valueView.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
                valueView.bottomAnchor.constraint(equalTo: rowView.bottomAnchor)
            ])
        }
        
        contentStackView.addArrangedSubview(rowView)
    }
    
    /// Returns a human-readable string for the given `UIStackView.Distribution`.
    private func stackDistributionName(_ distribution: UIStackView.Distribution) -> String {
        switch distribution {
        case .fill: return "Fill"
        case .fillEqually: return "Fill Equally"
        case .fillProportionally: return "Fill Proportionally"
        case .equalSpacing: return "Equal Spacing"
        case .equalCentering: return "Equal Centering"
        @unknown default: return "Unknown"
        }
    }
    
    /// Returns a human-readable string for the given `UIStackView.Alignment`.
    private func stackAlignmentName(_ alignment: UIStackView.Alignment) -> String {
        switch alignment {
        case .fill: return "Fill"
        case .leading: return "Leading"
        case .top: return "Top"
        case .firstBaseline: return "First Baseline"
        case .center: return "Center"
        case .trailing: return "Trailing"
        case .bottom: return "Bottom"
        case .lastBaseline: return "Last Baseline"
        @unknown default: return "Unknown"
        }
    }
    
    /// Returns a human-readable string for the given `NSTextAlignment`.
    private func textAlignmentName(_ alignment: NSTextAlignment) -> String {
        switch alignment {
        case .left:      return "Left"
        case .center:    return "Center"
        case .right:     return "Right"
        case .justified: return "Justified"
        case .natural:   return "Natural"
        @unknown default: return "Unknown"
        }
    }

    /// Returns a human-readable comma-separated description of `UIAccessibilityTraits`.
    private func accessibilityTraitsDescription(_ traits: UIAccessibilityTraits) -> String {
        var names: [String] = []
        if traits.contains(.button)            { names.append("Button") }
        if traits.contains(.link)              { names.append("Link") }
        if traits.contains(.image)             { names.append("Image") }
        if traits.contains(.header)            { names.append("Header") }
        if traits.contains(.selected)          { names.append("Selected") }
        if traits.contains(.notEnabled)        { names.append("Disabled") }
        if traits.contains(.adjustable)        { names.append("Adjustable") }
        if traits.contains(.staticText)        { names.append("Static Text") }
        if traits.contains(.searchField)       { names.append("Search Field") }
        if traits.contains(.tabBar)            { names.append("Tab Bar") }
        if traits.contains(.summaryElement)    { names.append("Summary") }
        if traits.contains(.updatesFrequently) { names.append("Updates Frequently") }
        if traits.contains(.causesPageTurn)    { names.append("Page Turn") }
        if traits.contains(.allowsDirectInteraction) { names.append("Direct Interaction") }
        if traits.contains(.playsSound)        { names.append("Plays Sound") }
        if traits.contains(.startsMediaSession){ names.append("Starts Media") }
        if traits.contains(.keyboardKey)       { names.append("Keyboard Key") }
        return names.isEmpty ? "None" : names.joined(separator: ", ")
    }

    /// Returns a human-readable string for the given `UIView.ContentMode`.
    private func contentModeName(_ mode: UIView.ContentMode) -> String {
        switch mode {
        case .scaleToFill: return "Scale To Fill"
        case .scaleAspectFit: return "Scale Aspect Fit"
        case .scaleAspectFill: return "Scale Aspect Fill"
        case .center: return "Center"
        case .top: return "Top"
        case .left: return "Left"
        case .right: return "Right"
        case .topLeft: return "Top Left"
        case .topRight: return "Top Right"
        case .bottomLeft: return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        case .redraw: return "Redraw"
        case .bottom: return "Bottom"
        @unknown default:
            return "Unknown"
        }
    }
}
