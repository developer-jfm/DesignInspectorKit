import UIKit

/// Demonstrates inspector on UISegmentedControl, UIPageControl, UIStepper and UIDatePicker.
final class AdditionalControlsExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "More Controls"
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

        // UISegmentedControl
        stack.addArrangedSubview(makeRow(label: "UISegmentedControl (index 1)") {
            let seg = UISegmentedControl(items: ["Day", "Week", "Month"])
            seg.selectedSegmentIndex = 1
            seg.accessibilityIdentifier = "example_segmented"
            return seg
        })

        // UIPageControl
        stack.addArrangedSubview(makeRow(label: "UIPageControl (3/5 pages)") {
            let pageControl = UIPageControl()
            pageControl.numberOfPages = 5
            pageControl.currentPage = 2
            pageControl.pageIndicatorTintColor = .systemGray4
            pageControl.currentPageIndicatorTintColor = .systemBlue
            pageControl.accessibilityIdentifier = "example_page_control"
            return pageControl
        })

        // UIStepper
        stack.addArrangedSubview(makeRow(label: "UIStepper (0–10, step 0.5, value 3.5)") {
            let stepper = UIStepper()
            stepper.minimumValue = 0
            stepper.maximumValue = 10
            stepper.stepValue = 0.5
            stepper.value = 3.5
            stepper.accessibilityIdentifier = "example_stepper"
            return stepper
        })

        // UIDatePicker – compact style
        stack.addArrangedSubview(makeRow(label: "UIDatePicker (date mode)") {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            if #available(iOS 14.0, *) {
                datePicker.preferredDatePickerStyle = .compact
            }
            let calendar = Calendar.current
            datePicker.minimumDate = calendar.date(byAdding: .year, value: -1, to: Date())
            datePicker.maximumDate = calendar.date(byAdding: .year, value: 1, to: Date())
            datePicker.accessibilityIdentifier = "example_date_picker"
            return datePicker
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
