import UIKit

/// Demonstrates inspector on `UILabel` and `UIButton` components.
///
/// Tap with 2 fingers to open the overlay, then tap any view below to inspect:
/// - `titleLabel`    — bold, large font, accessibilityIdentifier set
/// - `subtitleLabel` — multiline, secondary color
/// - `primaryButton` — filled style, cornerRadius, accessibilityLabel
/// - `secondaryButton` — outlined style, borderWidth + borderColor
/// - `badgeLabel`    — fixed size, clipsToBounds, red background
final class TextExampleViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UILabel & UIButton"
        view.backgroundColor = .systemBackground
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        // Root vertical stack that centers all example views on screen.
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

        // MARK: UILabel — large bold title
        let titleLabel = UILabel()
        titleLabel.text = "Design Inspector"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textColor = .label
        titleLabel.accessibilityIdentifier = "title_label"

        // MARK: UILabel — multiline subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Tap with 2 fingers anywhere to inspect views"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center

        // MARK: UIButton — filled primary style
        let primaryButton = UIButton(type: .system)
        primaryButton.setTitle("Primary Action", for: .normal)
        primaryButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        primaryButton.backgroundColor = .systemBlue
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.layer.cornerRadius = 12
        primaryButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        primaryButton.accessibilityIdentifier = "primary_button"
        primaryButton.accessibilityLabel = "Primary action button"

        // MARK: UIButton — outlined secondary style
        let secondaryButton = UIButton(type: .system)
        secondaryButton.setTitle("Secondary", for: .normal)
        secondaryButton.titleLabel?.font = .systemFont(ofSize: 15)
        secondaryButton.setTitleColor(.systemBlue, for: .normal)
        secondaryButton.layer.borderWidth = 1
        secondaryButton.layer.borderColor = UIColor.systemBlue.cgColor
        secondaryButton.layer.cornerRadius = 8
        secondaryButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        // MARK: UILabel — badge with fixed size and clipped corners
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
