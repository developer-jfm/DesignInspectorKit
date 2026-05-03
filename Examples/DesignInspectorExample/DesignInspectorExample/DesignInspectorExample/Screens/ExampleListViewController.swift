import UIKit

/// Root screen that lists all available inspector examples.
///
/// Each row navigates to a dedicated view controller that showcases a specific
/// UIKit component or feature that can be inspected with DesignInspectorKit.
final class ExampleListViewController: UITableViewController {

    // MARK: - Model

    /// Represents a single example entry in the list.
    private struct Example {
        /// Display title shown in the cell.
        let title: String
        /// Short description shown as secondary text.
        let subtitle: String
        /// Factory closure that creates the destination view controller.
        let maker: () -> UIViewController
    }

    // MARK: - Data

    /// All available example screens, in display order.
    private let examples: [Example] = [
        Example(
            title: "UILabel & UIButton",
            subtitle: "Text, font, color, corner radius",
            maker: { TextExampleViewController() }
        ),
        Example(
            title: "UIImageView",
            subtitle: "Image name, size, content mode",
            maker: { ImageExampleViewController() }
        ),
        Example(
            title: "UIStackView",
            subtitle: "Axis, distribution, alignment, spacing",
            maker: { StackViewExampleViewController() }
        ),
        Example(
            title: "UIScrollView",
            subtitle: "Content size, insets, paging",
            maker: { ScrollViewExampleViewController() }
        ),
        Example(
            title: "Controls",
            subtitle: "UISwitch, UISlider, UIProgressView, UIActivityIndicator",
            maker: { ControlsExampleViewController() }
        ),
        Example(
            title: "Accessibility",
            subtitle: "identifiers, labels, traits",
            maker: { AccessibilityExampleViewController() }
        ),
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DesignInspector Examples"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        examples.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let example = examples[indexPath.row]

        // Use the default content configuration to show title + subtitle.
        var config = cell.defaultContentConfiguration()
        config.text = example.title
        config.secondaryText = example.subtitle
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Instantiate and push the selected example view controller.
        let vc = examples[indexPath.row].maker()
        navigationController?.pushViewController(vc, animated: true)
    }
}
