import UIKit

/// Root screen listing all available inspector examples.
final class ExampleListViewController: UITableViewController {

    private struct Example {
        let title: String
        let subtitle: String
        let maker: () -> UIViewController
    }

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
        Example(
            title: "UISearchBar",
            subtitle: "Placeholder, text, style, cancel button, tint",
            maker: { SearchBarExampleViewController() }
        ),
        Example(
            title: "UITextView",
            subtitle: "Text, font, color, alignment",
            maker: { TextViewExampleViewController() }
        ),
        Example(
            title: "More Controls",
            subtitle: "UISegmentedControl, UIPageControl, UIStepper, UIDatePicker",
            maker: { AdditionalControlsExampleViewController() }
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DesignInspector Examples"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        examples.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let example = examples[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = example.title
        config.secondaryText = example.subtitle
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = examples[indexPath.row].maker()
        navigationController?.pushViewController(vc, animated: true)
    }
}
