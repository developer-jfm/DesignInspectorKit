import UIKit

/// Demonstrates inspector on UILabel and UIButton components.
final class TextExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UILabel & UIButton"
        view.backgroundColor = .systemBackground
        setupViews()
    }

    private func setupViews() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])

        let titleLabel = UILabel()
        titleLabel.text = "Design Inspector"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textColor = .label
        titleLabel.accessibilityIdentifier = "title_label"

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Long press anywhere to inspect views"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center

        let primaryButton = UIButton(type: .system)
        primaryButton.setTitle("Primary Action", for: .normal)
        primaryButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        primaryButton.backgroundColor = .systemBlue
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.layer.cornerRadius = 12
        primaryButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        primaryButton.accessibilityIdentifier = "primary_button"
        primaryButton.accessibilityLabel = "Primary action button"

        let secondaryButton = UIButton(type: .system)
        secondaryButton.setTitle("Secondary", for: .normal)
        secondaryButton.titleLabel?.font = .systemFont(ofSize: 15)
        secondaryButton.setTitleColor(.systemBlue, for: .normal)
        secondaryButton.layer.borderWidth = 1
        secondaryButton.layer.borderColor = UIColor.systemBlue.cgColor
        secondaryButton.layer.cornerRadius = 8
        secondaryButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        let badgeLabel = UILabel()
        badgeLabel.text = "NEW"
        badgeLabel.font = .boldSystemFont(ofSize: 11)
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = .systemRed
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.clipsToBounds = true
        badgeLabel.textAlignment = .center
        badgeLabel.widthAnchor.constraint(equalToConstant: 48).isActive = true
        badgeLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true

        [titleLabel, subtitleLabel, primaryButton, secondaryButton, badgeLabel].forEach {
            stack.addArrangedSubview($0)
        }
    }
}
