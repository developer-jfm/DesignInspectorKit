import UIKit

/// Demonstrates inspector on views with rich accessibility configuration.
///
/// Inspect each view to see:
/// - `accessibilityIdentifier` — used for UI testing
/// - `accessibilityLabel`      — read by VoiceOver
/// - `accessibilityTraits`     — semantic role (header, button, etc.)
/// - `isAccessibilityElement`  — whether VoiceOver focuses the view
final class AccessibilityExampleViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accessibility"
        view.backgroundColor = .systemBackground
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])

        // MARK: UILabel — marked as .header trait for VoiceOver navigation
        let titleLabel = UILabel()
        titleLabel.text = "Welcome banner"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .label
        titleLabel.accessibilityIdentifier = "welcome_banner"
        titleLabel.accessibilityLabel = "Welcome to the app"
        titleLabel.accessibilityTraits = .header
        titleLabel.isAccessibilityElement = true
        stack.addArrangedSubview(titleLabel)

        // MARK: UIButton — explicit .button trait and custom accessibilityLabel
        let actionButton = UIButton(type: .system)
        actionButton.setTitle("Continue", for: .normal)
        actionButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        actionButton.backgroundColor = .systemBlue
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.layer.cornerRadius = 12
        actionButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        actionButton.accessibilityIdentifier = "continue_button"
        actionButton.accessibilityLabel = "Continue to next screen"
        actionButton.accessibilityTraits = .button
        stack.addArrangedSubview(actionButton)

        // MARK: UIImageView — isAccessibilityElement = true so VoiceOver reads the label
        let iconImageView = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
        iconImageView.tintColor = .systemGreen
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        iconImageView.accessibilityIdentifier = "success_icon"
        iconImageView.accessibilityLabel = "Verification success icon"
        iconImageView.isAccessibilityElement = true
        stack.addArrangedSubview(iconImageView)

        // MARK: UIView — decorative divider, explicitly excluded from accessibility tree
        let decorView = UIView()
        decorView.backgroundColor = .systemFill
        decorView.layer.cornerRadius = 8
        decorView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        decorView.isAccessibilityElement = false // VoiceOver skips this view
        decorView.accessibilityIdentifier = "divider_line"
        stack.addArrangedSubview(decorView)

        // MARK: UITextField — identifier + label for UI test targeting
        let textField = UITextField()
        textField.placeholder = "Enter your name"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.accessibilityIdentifier = "name_text_field"
        textField.accessibilityLabel = "Name input field"
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stack.addArrangedSubview(textField)
    }
}
