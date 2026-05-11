import UIKit

/// Demonstrates inspector on UISearchBar components.
final class SearchBarExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UISearchBar"
        view.backgroundColor = .systemBackground
        setupViews()
    }

    private func setupViews() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 32
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])

        // Default style
        let defaultBar = UISearchBar()
        defaultBar.placeholder = "Search anything..."
        defaultBar.searchBarStyle = .default
        defaultBar.accessibilityIdentifier = "search_bar_default"
        stack.addArrangedSubview(makeRow(label: "Default style", view: defaultBar))

        // Minimal style
        let minimalBar = UISearchBar()
        minimalBar.placeholder = "Minimal search"
        minimalBar.searchBarStyle = .minimal
        minimalBar.showsCancelButton = true
        minimalBar.accessibilityIdentifier = "search_bar_minimal"
        stack.addArrangedSubview(makeRow(label: "Minimal + Cancel button", view: minimalBar))

        // With text and tint
        let tintedBar = UISearchBar()
        tintedBar.placeholder = "Tinted bar"
        tintedBar.text = "Hello"
        tintedBar.barTintColor = .systemIndigo
        tintedBar.tintColor = .systemOrange
        tintedBar.accessibilityIdentifier = "search_bar_tinted"
        stack.addArrangedSubview(makeRow(label: "With text & tint", view: tintedBar))
    }

    private func makeRow(label text: String, view searchView: UIView) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel

        container.addArrangedSubview(label)
        container.addArrangedSubview(searchView)
        return container
    }
}
