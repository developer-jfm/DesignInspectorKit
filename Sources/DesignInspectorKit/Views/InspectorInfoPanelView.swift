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
    }
    
    private let configuration: InspectorConfiguration
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = configuration.panelBackgroundColor
        view.layer.cornerRadius = Layout.cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = configuration.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var contentStackview: UIStackView = {
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
        scroll.alwaysBounceVertical = true
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
        fatalError("")
    }
    
    private func setupUI() {
        addSubview(scrollView)

        scrollView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentStackview)

        NSLayoutConstraint.activate([
            // scrollView fills the entire panel view
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // containerView follows the scroll's content layout guide so it can grow taller than the frame
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            // pin width to frame layout guide to prevent horizontal scrolling
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Layout.padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.padding),

            contentStackview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.spacing),
            contentStackview.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.padding),
            contentStackview.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.padding),
            contentStackview.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Layout.padding),
        ])
    }
    
    /// Populates the panel with data from the given `ViewInspectorInfo`.
    /// Clears any previously displayed content before rendering.
    /// - Parameter info: The inspected view's property snapshot.
    func configure(with info: ViewInspectorInfo) {
        titleLabel.text = info.className
        contentStackview.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
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

        if let renderedSize = info.imageRenderedSize, renderedSize.width > 0 && renderedSize.height > 0 {
            addInfoRow(label: InspectorKey.imageSize, value: "\(Int(renderedSize.width)) x \(Int(renderedSize.height)) pt")
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
                spacingValue = "\(token) (\(spacing)pt)"
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

        if info.borderWidth > 0 {
            addInfoRow(label: InspectorKey.borderWidth, value: "\(info.borderWidth)pt")
        }

        if let borderColor = info.borderColor {
            addInfoRow(label: InspectorKey.borderColor, value: borderColor.hexString, color: borderColor)
        }

        if let tintColor = info.tintColor {
            addInfoRow(label: InspectorKey.tintColor, value: tintColor.hexString, color: tintColor)
        }

        // MARK: UIStackView
        if let axis = info.stackAxis {
            addInfoRow(label: "Axis", value: axis == .horizontal ? "Horizontal" : "Vertical")
        }
        if let distribution = info.stackDistribution {
            addInfoRow(label: "Distribution", value: stackDistributionName(distribution))
        }
        if let alignment = info.stackAlignment {
            addInfoRow(label: "Alignment", value: stackAlignmentName(alignment))
        }

        // MARK: UIScrollView
        if let contentSize = info.scrollContentSize {
            addInfoRow(label: "Content Size", value: "\(Int(contentSize.width)) x \(Int(contentSize.height)) pt")
        }
        if let paging = info.scrollIsPagingEnabled {
            addInfoRow(label: "Paging", value: paging ? "Enabled" : "Disabled")
        }
        if let insets = info.contentInsets {
            addInfoRow(label: InspectorKey.contentInsets, value: "T:\(Int(insets.top)) L:\(Int(insets.left)) B:\(Int(insets.bottom)) R:\(Int(insets.right))")
        }

        // MARK: UISwitch
        if let isOn = info.switchIsOn {
            addInfoRow(label: "Is On", value: isOn ? "true" : "false")
        }
        if let onTint = info.switchOnTintColor {
            addInfoRow(label: "On Tint", value: onTint.hexString, color: onTint)
        }
        if let thumbTint = info.switchThumbTintColor {
            addInfoRow(label: "Thumb Tint", value: thumbTint.hexString, color: thumbTint)
        }

        // MARK: UISlider
        if let sliderValue = info.sliderValue, let minVal = info.sliderMinValue, let maxVal = info.sliderMaxValue {
            addInfoRow(label: "Value", value: String(format: "%.2f", sliderValue))
            addInfoRow(label: "Range", value: "\(minVal) – \(maxVal)")
        }

        // MARK: UIProgressView
        if let progress = info.progressValue {
            addInfoRow(label: "Progress", value: String(format: "%.0f%%", progress * 100))
        }
        if let progressTint = info.progressTintColor {
            addInfoRow(label: "Progress Tint", value: progressTint.hexString, color: progressTint)
        }

        // MARK: UIActivityIndicatorView
        if let animating = info.activityIsAnimating {
            addInfoRow(label: "Animating", value: animating ? "true" : "false")
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

        // MARK: Hierarchy
        addInfoRow(label: InspectorKey.subviewsCount, value: "\(info.subviewsCount)")
        addInfoRow(label: InspectorKey.depth, value: "\(info.depth)")
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
                labelView.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.labelWidth),
                
                valueView.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: Layout.spacing),
                valueView.topAnchor.constraint(equalTo: rowView.topAnchor),
                valueView.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
                valueView.bottomAnchor.constraint(equalTo: rowView.bottomAnchor)
            ])
        }
        
        contentStackview.addArrangedSubview(rowView)
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
