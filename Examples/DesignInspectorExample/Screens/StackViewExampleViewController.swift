import UIKit

/// Demonstrates inspector on UIStackView with different axis, distribution and alignment.
final class StackViewExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIStackView"
        view.backgroundColor = .systemBackground
        setupViews()
    }

    private func setupViews() {
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

        root.addArrangedSubview(makeSectionLabel("Horizontal · Fill Equally · spacing 8"))
        root.addArrangedSubview(makeHorizontalStack())

        root.addArrangedSubview(makeSectionLabel("Vertical · Equal Spacing · Center"))
        root.addArrangedSubview(makeVerticalStack())
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    private func makeHorizontalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 8

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

    private func makeVerticalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 12

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
