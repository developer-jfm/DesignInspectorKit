//
//  File.swift
//  DesignInspectorKit
//
//  Created by Josimar Fiuza Melo on 02/05/26.
//

import Foundation
import UIKit

/// A full-screen overlay view controller that allows the user to tap any view
/// and inspect its layout, colors, fonts, spacing, constraints, and accessibility properties.
///
/// Present this view controller modally with `.overFullScreen` to keep the inspected
/// screen visible behind the overlay.
public final class InspectorOverlayViewController: UIViewController {
    
    private enum Layout {
        static let padding: CGFloat = 16
        static let topPadding: CGFloat = 12
        static let closeButtonSize: CGFloat = 32
        static let cornerRadius: CGFloat = 12
        static let instructionWidth: CGFloat = 280
        static let instructionHeight: CGFloat = 50
        static let deactivateWidth: CGFloat = 220
    }
    
    private let targetView: UIView
    private let navigationBar: UINavigationBar?
    private let configuration: InspectorConfiguration
    private var selectedView: UIView?
    private var highlightLayer: CAShapeLayer?
    private var constraintLayer: [CALayer] = []
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
        button.setTitle("close", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.accessibilityIdentifier = "inspector_close_button"
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var infoPanel: InspectorInfoPanelView = {
        let panel = InspectorInfoPanelView(configuration: configuration)
        panel.accessibilityHint = "Swipe up to dismiss"
        panel.isHidden = true
        panel.translatesAutoresizingMaskIntoConstraints = false
        return panel
    }()
    
    private lazy var deactivateLabel: UILabel = {
        let label = UILabel()
        label.text = "Long press to exit"
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
    ///   - configuration: The appearance and token resolver configuration.
    public init(targetView: UIView, navigationBar: UINavigationBar? = nil, configuration: InspectorConfiguration) {
        self.targetView = targetView
        self.navigationBar = navigationBar
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        animateInstructionLabel()
    }
    
    private func setupUI() {
        view.backgroundColor = configuration.overlayBackgroundColor
        
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
            
            infoPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            infoPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            infoPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.padding),
            
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
    
    @objc private func closeButtonTapped() {
        guard !isClosing else { return }
        isClosing = true
        
        instructionLabel.layer.removeAllAnimations()
        showDesactivateMessage()
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
    
    private func showDesactivateMessage() {
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
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard !isClosing else { return }
        let location = gesture.location(in: view)
        
        if let navBar = navigationBar {
            let locationInNavBar = view.convert(location, to: navBar)
            if navBar.bounds.contains(locationInNavBar),
               let tappedView = navBar.deepesView(at: locationInNavBar) {
                selectView(tappedView)
                return
            }
        }
        
        let locationInTarget = view.convert(location, to: targetView)
        
        if let tappedView = targetView.deepesView(at: locationInTarget) {
            selectView(tappedView)
        }
    }
    
    /// Selects a view for inspection: highlights its frame, draws spacing annotations,
    /// and populates the info panel with the view's properties.
    /// - Parameter view: The view to inspect.
    private func selectView(_ view: UIView) {
        selectedView = view
        
        
        highlightLayer?.removeFromSuperlayer()
        removeConstraintsLayers()
        
        let frameInSelf = view.convert(view.bounds, to: self.view)
        
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(rect: frameInSelf).cgPath
        layer.fillColor = configuration.highlightColor.cgColor
        layer.strokeColor = configuration.annotationColor.cgColor
        layer.lineWidth = 1
        self.view.layer.addSublayer(layer)
        highlightLayer = layer
        
        drawConstraintVisualizations(for: view, frameInSelf: frameInSelf)
        
        let inspector = ViewHierachyInspector(configuration: configuration)
        let info = inspector.inspectSingle(view)
        infoPanel.configure(with: info)
        infoPanel.isHidden = false
        
        infoPanel.alpha = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.infoPanel.alpha = 1
        }
    }
    
    private func removeConstraintsLayers() {
        constraintLayer.forEach { $0.removeFromSuperlayer() }
        constraintLayer.removeAll()
    }
    
    /// Draws dashed spacing lines from the selected view's edges to its superview's edges.
    /// - Parameters:
    ///   - view: The selected view.
    ///   - frameInSelf: The view's frame converted to the overlay's coordinate space.
    private func drawConstraintVisualizations(for view: UIView, frameInSelf: CGRect) {
        let constraintColor = UIColor.systemBlue
        
        guard let superView = view.superview else { return }
        let superFrameInSelf = superView.convert(superView.bounds, to: self.view)

        let topSpacing = view.frame.minY
        if topSpacing > 0 {
            drawSpacingLine(
                from: CGPoint(x: frameInSelf.midX, y: superFrameInSelf.minY),
                to:   CGPoint(x: frameInSelf.midX, y: frameInSelf.minY),
                value: topSpacing,
                color: constraintColor,
                isVertical: true
            )
        }

        let bottomSpacing = superView.bounds.height - view.frame.maxY
        if bottomSpacing > 0 {
            drawSpacingLine(
                from: CGPoint(x: frameInSelf.midX, y: frameInSelf.maxY),
                to:   CGPoint(x: frameInSelf.midX, y: superFrameInSelf.maxY),
                value: bottomSpacing,
                color: constraintColor,
                isVertical: true
            )
        }

        let leadingSpacing = view.frame.minX
        if leadingSpacing > 0 {
            drawSpacingLine(
                from: CGPoint(x: superFrameInSelf.minX, y: frameInSelf.midY),
                to:   CGPoint(x: frameInSelf.minX,      y: frameInSelf.midY),
                value: leadingSpacing,
                color: constraintColor,
                isVertical: false
            )
        }

        let trailingSpacing = superView.bounds.width - view.frame.maxX
        if trailingSpacing > 0 {
            drawSpacingLine(
                from: CGPoint(x: frameInSelf.maxX,      y: frameInSelf.midY),
                to:   CGPoint(x: superFrameInSelf.maxX, y: frameInSelf.midY),
                value: trailingSpacing,
                color: constraintColor,
                isVertical: false
            )
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
        guard value > 4 else { return }
        
        let lineLayer = CAShapeLayer()
        let path = UIBezierPath()
        
        path.move(to: start)
        path.addLine(to: end)
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = color.cgColor
        lineLayer.lineWidth = 1
        lineLayer.lineDashPattern = [4, 2]
        lineLayer.fillColor = nil
        self.view.layer.addSublayer(lineLayer)
        constraintLayer.append(lineLayer)
        
        
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
        self.view.layer.addSublayer(capLayer)
        constraintLayer.append(capLayer)
        
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
        textLayer.backgroundColor = color.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.cornerRadius = 3
        
        let textSize = (text as NSString).size(withAttributes: [.font: font])
        let padding: CGFloat = 4
        let labelSize = CGSize(width: textSize.width + padding * 2, height: textSize.height + padding)
        textLayer.frame = CGRect(
            x: point.x - labelSize.width / 2,
            y: point.y - labelSize.height / 2,
            width: labelSize.width,
            height: labelSize.height
        )
        self.view.layer.addSublayer(textLayer)
        constraintLayer.append(textLayer)
    }
}
