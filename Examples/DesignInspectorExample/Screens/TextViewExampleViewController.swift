import UIKit

/// Demonstrates inspector on UITextView components.
final class TextViewExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UITextView"
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
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])

        // Basic text view
        let basicLabel = makeLabel("Basic UITextView")
        stack.addArrangedSubview(basicLabel)

        let basicTextView = UITextView()
        basicTextView.text = "This is a basic UITextView with multiple lines of content to demonstrate text wrapping and font inspection."
        basicTextView.font = .systemFont(ofSize: 16)
        basicTextView.textColor = .label
        basicTextView.backgroundColor = .secondarySystemBackground
        basicTextView.layer.cornerRadius = 8
        basicTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        basicTextView.isEditable = false
        basicTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        basicTextView.accessibilityIdentifier = "basic_text_view"
        stack.addArrangedSubview(basicTextView)

        // Styled text view
        let styledLabel = makeLabel("Styled UITextView")
        stack.addArrangedSubview(styledLabel)

        let styledTextView = UITextView()
        styledTextView.text = "Styled text with custom font and color."
        styledTextView.font = .italicSystemFont(ofSize: 18)
        styledTextView.textColor = .systemPurple
        styledTextView.backgroundColor = .systemPurple.withAlphaComponent(0.08)
        styledTextView.layer.cornerRadius = 12
        styledTextView.layer.borderWidth = 1
        styledTextView.layer.borderColor = UIColor.systemPurple.cgColor
        styledTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        styledTextView.isEditable = false
        styledTextView.textAlignment = .center
        styledTextView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        styledTextView.accessibilityIdentifier = "styled_text_view"
        stack.addArrangedSubview(styledTextView)

        // Editable text view
        let editableLabel = makeLabel("Editable UITextView")
        stack.addArrangedSubview(editableLabel)

        let editableTextView = UITextView()
        editableTextView.text = "Tap to edit this text view..."
        editableTextView.font = .systemFont(ofSize: 14)
        editableTextView.textColor = .label
        editableTextView.backgroundColor = .systemBackground
        editableTextView.layer.cornerRadius = 8
        editableTextView.layer.borderWidth = 1
        editableTextView.layer.borderColor = UIColor.separator.cgColor
        editableTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        editableTextView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        editableTextView.accessibilityIdentifier = "editable_text_view"
        editableTextView.accessibilityLabel = "Editable text area"
        stack.addArrangedSubview(editableTextView)
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }
}
