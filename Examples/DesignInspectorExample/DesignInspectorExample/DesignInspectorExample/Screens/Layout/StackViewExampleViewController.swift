import UIKit

/// Demonstrates inspector on `UIStackView` with different axis, distribution and alignment.
///
/// Two stack views are shown:
/// - Horizontal stack with `fillEqually` distribution
/// - Vertical stack with `equalSpacing` distribution and `center` alignment
///
/// Inspect each stack to see axis, distribution, alignment and spacing in the panel.
final class StackViewExampleViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIStackView"
        view.backgroundColor = .systemBackground
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        // Root stack that holds section labels and the two example stacks.
        let root = UIStackView()
        root.axis = .vertical
        root.spacing = 32
        root.alignment = .fill
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)

        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])

        // Section 1: horizontal stack
        root.addArrangedSubview(makeSectionLabel("Horizontal · Fill Equally · spacing 8"))
        root.addArrangedSubview(makeHorizontalStack())

        // Section 2: vertical stack
        root.addArrangedSubview(makeSectionLabel("Vertical · Equal Spacing · Center"))
        root.addArrangedSubview(makeVerticalStack())
    }

    // MARK: - Helpers

    /// Creates a small section header label.
    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    /// Horizontal stack — `fillEqually` distributes the three colored boxes evenly.
    private func makeHorizontalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 8

        // Three boxes with different colors to make individual views easy to tap.
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange]
        colors.forEach { color in
            let box = UIView()
            box.backgroundColor = color.withAlphaComponent(0.3)
            box.layer.cornerRadius = 8
            box.heightAnchor.constraint(equalToConstant: 60).isActive = true
            stack.addArrangedSubview(box)
        }
        return stack
    }

    /// Vertical stack — `equalSpacing` keeps uniform gaps between boxes of different sizes.
    private func makeVerticalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 12

        // Boxes with varying sizes to illustrate equalSpacing behaviour.
        let sizes: [CGFloat] = [44, 56, 36]
        let colors: [UIColor] = [.systemPurple, .systemTeal, .systemPink]
        zip(sizes, colors).forEach { size, color in
            let box = UIView()
            box.backgroundColor = color.withAlphaComponent(0.3)
            box.layer.cornerRadius = size / 4
            box.widthAnchor.constraint(equalToConstant: size * 2).isActive = true
            box.heightAnchor.constraint(equalToConstant: size).isActive = true
            stack.addArrangedSubview(box)
        }
        return stack
    }
}
