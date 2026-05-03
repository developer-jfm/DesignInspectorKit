import UIKit

/// Demonstrates inspector on `UIScrollView` with a tall content area.
///
/// Nine colored cards are stacked vertically inside the scroll view.
/// Inspect the scroll view itself to see: contentSize, contentInset, isPagingEnabled.
/// Inspect individual cards to see frame, backgroundColor, cornerRadius.
final class ScrollViewExampleViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIScrollView"
        view.backgroundColor = .systemBackground
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        // Scroll view fills the safe area.
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = false
        scrollView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.accessibilityIdentifier = "example_scroll_view"
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Content stack anchored to the scroll view's contentLayoutGuide so it
        // can grow taller than the visible frame and enable vertical scrolling.
        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            // Pin width to frame layout guide to prevent horizontal scrolling.
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
        ])

        // Nine spectrum-like colors, each becoming a tappable card.
        let colors: [UIColor] = [
            .systemRed, .systemOrange, .systemYellow,
            .systemGreen, .systemBlue, .systemIndigo,
            .systemPurple, .systemPink, .systemTeal,
        ]

        colors.enumerated().forEach { index, color in
            // Each card has a tinted background, rounded corners and a colored border.
            let card = UIView()
            card.backgroundColor = color.withAlphaComponent(0.25)
            card.layer.cornerRadius = 16
            card.layer.borderWidth = 1
            card.layer.borderColor = color.cgColor
            card.heightAnchor.constraint(equalToConstant: 100).isActive = true
            card.accessibilityIdentifier = "card_\(index)"

            let label = UILabel()
            label.text = "Card \(index + 1)"
            label.font = .boldSystemFont(ofSize: 18)
            label.textColor = color
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)

            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            ])

            content.addArrangedSubview(card)
        }
    }
}
