import UIKit

/// Demonstrates inspector on views with accessibility properties configured.
final class AccessibilityExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accessibility"
        view.backgroundColor = .systemBackground
        setupViews()
    }

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

        // Label with accessibility
        let titleLabel = UILabel()
        titleLabel.text = "Welcome banner"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .label
        titleLabel.accessibilityIdentifier = "welcome_banner"
        titleLabel.accessibilityLabel = "Welcome to the app"
        titleLabel.accessibilityTraits = .header
        titleLabel.isAccessibilityElement = true
        stack.addArrangedSubview(titleLabel)

        // Button with accessibility
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

        // Image with accessibility
        let iconImageView = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
        iconImageView.tintColor = .systemGreen
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        iconImageView.accessibilityIdentifier = "success_icon"
        iconImageView.accessibilityLabel = "Verification success icon"
        iconImageView.isAccessibilityElement = true
        stack.addArrangedSubview(iconImageView)

        // Non-accessible decorative view
        let decorView = UIView()
        decorView.backgroundColor = .systemFill
        decorView.layer.cornerRadius = 8
        decorView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        decorView.isAccessibilityElement = false
        decorView.accessibilityIdentifier = "divider_line"
        stack.addArrangedSubview(decorView)

        // TextField
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
