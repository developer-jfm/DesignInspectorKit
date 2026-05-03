import UIKit

/// Demonstrates inspector on UISwitch, UISlider, UIProgressView and UIActivityIndicatorView.
final class ControlsExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Controls"
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
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])

        // UISwitch
        stack.addArrangedSubview(makeRow(label: "UISwitch (on)") {
            let sw = UISwitch()
            sw.isOn = true
            sw.onTintColor = .systemGreen
            sw.accessibilityIdentifier = "example_switch"
            return sw
        })

        stack.addArrangedSubview(makeRow(label: "UISwitch (off)") {
            let sw = UISwitch()
            sw.isOn = false
            sw.onTintColor = .systemBlue
            return sw
        })

        // UISlider
        stack.addArrangedSubview(makeRow(label: "UISlider (0–100, value 42)") {
            let slider = UISlider()
            slider.minimumValue = 0
            slider.maximumValue = 100
            slider.value = 42
            slider.tintColor = .systemBlue
            slider.accessibilityIdentifier = "example_slider"
            return slider
        })

        // UIProgressView
        stack.addArrangedSubview(makeRow(label: "UIProgressView (75%)") {
            let progress = UIProgressView(progressViewStyle: .default)
            progress.progress = 0.75
            progress.progressTintColor = .systemOrange
            progress.accessibilityIdentifier = "example_progress"
            return progress
        })

        // UIActivityIndicatorView
        stack.addArrangedSubview(makeRow(label: "UIActivityIndicatorView") {
            let activity = UIActivityIndicatorView(style: .medium)
            activity.startAnimating()
            activity.color = .systemPurple
            activity.accessibilityIdentifier = "example_activity"
            return activity
        })
    }

    private func makeRow(label text: String, control maker: () -> UIView) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 16
        row.alignment = .center

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let control = maker()
        control.setContentHuggingPriority(.required, for: .horizontal)

        row.addArrangedSubview(label)
        row.addArrangedSubview(control)
        return row
    }
}
