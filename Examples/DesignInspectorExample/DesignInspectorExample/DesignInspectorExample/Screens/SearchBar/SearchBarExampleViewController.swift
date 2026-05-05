import UIKit

/// Demonstrates inspector on UISearchBar components.
///
/// Shows different search bar configurations:
/// - Default style with placeholder
/// - Minimal style with cancel button
/// - Prominent style with tint color
/// - Pre-filled search text
final class SearchBarExampleViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UISearchBar"
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
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])

        // MARK: Default style with placeholder
        stack.addArrangedSubview(makeSection(label: "Default — with placeholder") {
            let bar = UISearchBar()
            bar.searchBarStyle = .default
            bar.placeholder = "Search items..."
            bar.accessibilityIdentifier = "search_default"
            return bar
        })

        // MARK: Minimal style with cancel button
        stack.addArrangedSubview(makeSection(label: "Minimal — cancel button visible") {
            let bar = UISearchBar()
            bar.searchBarStyle = .minimal
            bar.placeholder = "Filter..."
            bar.showsCancelButton = true
            bar.accessibilityIdentifier = "search_minimal"
            return bar
        })

        // MARK: Prominent style with tint color
        stack.addArrangedSubview(makeSection(label: "Prominent — custom tint") {
            let bar = UISearchBar()
            bar.searchBarStyle = .prominent
            bar.placeholder = "Search products..."
            bar.tintColor = .systemPurple
            bar.barTintColor = .systemIndigo
            bar.accessibilityIdentifier = "search_prominent"
            return bar
        })

        // MARK: Pre-filled text
        stack.addArrangedSubview(makeSection(label: "Pre-filled search text") {
            let bar = UISearchBar()
            bar.searchBarStyle = .minimal
            bar.placeholder = "Type here..."
            bar.text = "DesignInspector"
            bar.accessibilityIdentifier = "search_prefilled"
            return bar
        })
    }

    // MARK: - Helpers

    private func makeSection(label: String, maker: () -> UISearchBar) -> UIView {
        let container = UIView()

        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let searchBar = maker()
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(titleLabel)
        container.addSubview(searchBar)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            searchBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }
}
