//
//  File.swift
//  DesignInspectorKit
//
//

import UIKit
import Combine

/// A full-screen overlay view controller that allows the user to tap any view
/// and inspect its layout, colors, fonts, spacing, constraints, and accessibility properties.
///
/// Observes `InspectorViewModel.$state` (Combine) and reacts to state changes.
/// Contains zero business logic — all decisions are delegated to the ViewModel.
public final class InspectorOverlayViewController: UIViewController {

    private enum Layout {
        static let padding: CGFloat = 16
        static let topPadding: CGFloat = 12
        static let closeButtonSize: CGFloat = 32
        static let instructionWidth: CGFloat = 280
        static let instructionHeight: CGFloat = 50
        static let deactivateWidth: CGFloat = 220
        static let panelMaxHeightRatio: CGFloat = 0.45
        /// Minimum spacing value (pt) required before drawing an annotation line and label.
        /// Values smaller than this produce overlapping caps and unreadable labels.
        static let minAnnotationSpacing: CGFloat = 4
    }

    private let targetView: UIView
    private let navigationBar: UINavigationBar?
    private let viewModel: InspectorViewModel
    private var cancellables = Set<AnyCancellable>()
    private var highlightLayer: CAShapeLayer?
    private var spacingLayers: [CALayer] = []
    private var isClosing = false
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.text = InspectorKey.tapToInspect
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.alpha = 0
        label.accessibilityIdentifier = "inspector_instruction_label"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.accessibilityLabel = InspectorKey.close
        button.accessibilityIdentifier = "inspector_close_button"
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var infoPanel: InspectorInfoPanelView = {
        let panel = InspectorInfoPanelView(configuration: viewModel.configuration)
        panel.isHidden = true
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.onClose = { [weak self] in
            self?.viewModel.clearSelection()
        }
        return panel
    }()
    
    private lazy var deactivateLabel: UILabel = {
        let label = UILabel()
        label.text = InspectorKey.longPressToExit
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.alpha = 0
        label.accessibilityIdentifier = "inspector_deactivate_label"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Creates an inspector overlay for the given view.
    /// - Parameters:
    ///   - targetView: The root view to be inspected (typically `viewController.view`).
    ///   - navigationBar: An optional navigation bar to include in the inspectable area.
    ///   - viewModel: The ViewModel driving this overlay.
    public init(targetView: UIView, navigationBar: UINavigationBar? = nil, viewModel: InspectorViewModel) {
        self.targetView = targetView
        self.navigationBar = navigationBar
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        bindViewModel()
        animateInstructionLabel()
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.renderState(state) }
            .store(in: &cancellables)
    }

    private func renderState(_ state: InspectorState) {
        switch state {
        case .idle: break
        case .active: clearHighlight()
        case .selected(let selection): showSelection(selection)
        }
    }

    // MARK: - State rendering

    private func showSelection(_ selection: InspectorSelection) {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.prepare()
        feedback.impactOccurred()

        highlightLayer?.removeFromSuperlayer()
        removeSpacingLayers()

        let layer = CAShapeLayer()
        layer.path = UIBezierPath(rect: selection.frameInOverlay).cgPath
        layer.fillColor = viewModel.configuration.highlightColor.cgColor
        layer.strokeColor = viewModel.configuration.annotationColor.cgColor
        layer.lineWidth = 1
        view.layer.addSublayer(layer)
        highlightLayer = layer

        if let superFrame = selection.superviewFrameInOverlay {
            drawSpacingAnnotations(selFrame: selection.frameInOverlay, superFrame: superFrame)
        }

        infoPanel.configure(with: selection.info)
        infoPanel.alpha = 0
        infoPanel.isHidden = false
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.infoPanel.alpha = 1
            self?.dimmingView.alpha = 1
        }
    }

    private func clearHighlight() {
        highlightLayer?.removeFromSuperlayer()
        highlightLayer = nil
        removeSpacingLayers()
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.infoPanel.alpha = 0
            self?.dimmingView.alpha = 0
        } completion: { [weak self] _ in
            self?.infoPanel.isHidden = true
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = viewModel.configuration.overlayBackgroundColor

        if let navBar = navigationBar, let navSnapshot = navBar.snapshotView(afterScreenUpdates: false) {
            navSnapshot.frame = navBar.frame
            navSnapshot.isUserInteractionEnabled = true
            view.addSubview(navSnapshot)
        }
        if let snapshot = targetView.snapshotView(afterScreenUpdates: false) {
            snapshot.frame = targetView.frame
            snapshot.isUserInteractionEnabled = true
            view.addSubview(snapshot)
        }
        
        view.addSubview(instructionLabel)
        view.addSubview(closeButton)
        view.addSubview(deactivateLabel)
        view.addSubview(dimmingView)
        view.addSubview(infoPanel)
        view.bringSubviewToFront(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.topPadding),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            closeButton.widthAnchor.constraint(equalToConstant: Layout.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Layout.closeButtonSize),
            
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            instructionLabel.widthAnchor.constraint(equalToConstant: Layout.instructionWidth),
            instructionLabel.heightAnchor.constraint(equalToConstant: Layout.instructionHeight),
            
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            infoPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            infoPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            infoPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.padding),
            infoPanel.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: Layout.panelMaxHeightRatio),

            deactivateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deactivateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            deactivateLabel.widthAnchor.constraint(equalToConstant: Layout.deactivateWidth),
            deactivateLabel.heightAnchor.constraint(equalToConstant: Layout.instructionHeight)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Touch

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard !isClosing else { return }
        let pointInOverlay = gesture.location(in: view)
        let windowPoint: CGPoint
        if let window = targetView.window {
            windowPoint = view.convert(pointInOverlay, to: window)
        } else {
            windowPoint = pointInOverlay
        }
        viewModel.onTap(in: targetView, navigationBar: navigationBar, at: windowPoint, overlayView: view)
    }

    // MARK: - Close

    @objc private func closeButtonTapped() {
        guard !isClosing else { return }
        isClosing = true
        
        instructionLabel.layer.removeAllAnimations()
        showDeactivateMessage()
    }
    
    private func animateInstructionLabel() {
        guard !isClosing else { return }
        instructionLabel.alpha = 0
        instructionLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard self?.isClosing == false else { return }
            self?.instructionLabel.alpha = 1
            self?.instructionLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { [weak self] _ in
            guard self?.isClosing == false else { return }
            UIView.animate(withDuration: 0.2) {
                self?.instructionLabel.transform = .identity
            } completion: { _ in
                guard self?.isClosing == false else { return }
                UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseInOut) {
                    self?.instructionLabel.alpha = 0
                    self?.instructionLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            }
        }
    }
    
    private func showDeactivateMessage() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.deactivateLabel.alpha = 1
            self?.deactivateLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2) {
                self?.deactivateLabel.transform = .identity
            } completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Spacing annotations

    private func removeSpacingLayers() {
        spacingLayers.forEach { $0.removeFromSuperlayer() }
        spacingLayers.removeAll()
    }

    private func drawSpacingAnnotations(selFrame: CGRect, superFrame: CGRect) {
        let color = viewModel.configuration.annotationColor

        let topSpacing    = selFrame.minY - superFrame.minY
        let bottomSpacing  = superFrame.maxY - selFrame.maxY
        let leadingSpacing = selFrame.minX - superFrame.minX
        let trailingSpacing = superFrame.maxX - selFrame.maxX

        if topSpacing > 0 {
            drawSpacingLine(from: CGPoint(x: selFrame.midX, y: superFrame.minY),
                            to: CGPoint(x: selFrame.midX, y: selFrame.minY),
                            value: topSpacing, color: color, isVertical: true)
        }
        if bottomSpacing > 0 {
            drawSpacingLine(from: CGPoint(x: selFrame.midX, y: selFrame.maxY),
                            to: CGPoint(x: selFrame.midX, y: superFrame.maxY),
                            value: bottomSpacing, color: color, isVertical: true)
        }
        if leadingSpacing > 0 {
            drawSpacingLine(from: CGPoint(x: superFrame.minX, y: selFrame.midY),
                            to: CGPoint(x: selFrame.minX, y: selFrame.midY),
                            value: leadingSpacing, color: color, isVertical: false)
        }
        if trailingSpacing > 0 {
            drawSpacingLine(from: CGPoint(x: selFrame.maxX, y: selFrame.midY),
                            to: CGPoint(x: superFrame.maxX, y: selFrame.midY),
                            value: trailingSpacing, color: color, isVertical: false)
        }
    }
    
    /// Draws a single dashed annotation line with end caps and a value label.
    /// - Parameters:
    ///   - start: The starting point of the line.
    ///   - end: The ending point of the line.
    ///   - value: The numeric spacing value to display.
    ///   - color: The color of the line and label.
    ///   - isVertical: Whether the end caps should be drawn horizontally (for vertical lines).
    private func drawSpacingLine(from start: CGPoint, to end: CGPoint, value: CGFloat, color: UIColor, isVertical: Bool) {
        guard value > Layout.minAnnotationSpacing else { return }
        
        let lineLayer = CAShapeLayer()
        let path = UIBezierPath()
        
        path.move(to: start)
        path.addLine(to: end)
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = color.cgColor
        lineLayer.lineWidth = 1
        lineLayer.lineDashPattern = [4, 2]
        lineLayer.fillColor = nil
        view.layer.addSublayer(lineLayer)
        spacingLayers.append(lineLayer)

        let capLength: CGFloat = 6
        if isVertical {
            drawCap(at: start, horizontal: true, length: capLength, color: color)
            drawCap(at: end, horizontal: true, length: capLength, color: color)
        } else {
            drawCap(at: start, horizontal: false, length: capLength, color: color)
            drawCap(at: end, horizontal: false, length: capLength, color: color)
        }
        
        let midPoint = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        drawValueLabel(at: midPoint, value: value, color: color)
    }
    
    /// Draws a short perpendicular cap line at the end of a spacing annotation line.
    private func drawCap(at point: CGPoint, horizontal: Bool, length: CGFloat, color: UIColor) {
        let capLayer = CAShapeLayer()
        let path = UIBezierPath()

        if horizontal {
            path.move(to: CGPoint(x: point.x - length / 2, y: point.y))
            path.addLine(to: CGPoint(x: point.x + length / 2, y: point.y))
        } else {
            path.move(to: CGPoint(x: point.x, y: point.y - length / 2))
            path.addLine(to: CGPoint(x: point.x, y: point.y + length / 2))
        }
        
        capLayer.path = path.cgPath
        capLayer.strokeColor = color.cgColor
        capLayer.lineWidth = 1
        view.layer.addSublayer(capLayer)
        spacingLayers.append(capLayer)
    }
    
    /// Draws a small pill-shaped label showing the spacing value at the midpoint of a line.
    private func drawValueLabel(at point: CGPoint, value: CGFloat, color: UIColor) {
        let text = "\(Int(value))"
        let font = UIFont.systemFont(ofSize: 10, weight: .semibold)

        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.font = font
        textLayer.fontSize = 10
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
        textLayer.borderColor = color.cgColor
        textLayer.borderWidth = 1
        textLayer.contentsScale = view.window?.screen.scale ?? UIScreen.main.scale
        textLayer.cornerRadius = 4
        textLayer.alignmentMode = .center

        let textSize = (text as NSString).size(withAttributes: [.font: font])
        let padding: CGFloat = 4
        let labelSize = CGSize(width: textSize.width + padding * 2, height: textSize.height + padding)
        textLayer.frame = CGRect(
            x: point.x - labelSize.width / 2,
            y: point.y - labelSize.height / 2,
            width: labelSize.width,
            height: labelSize.height
        )
        view.layer.addSublayer(textLayer)
        spacingLayers.append(textLayer)
    }
}
