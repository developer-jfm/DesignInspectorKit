import UIKit

/// Demonstrates inspector on UIImageView components.
final class ImageExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIImageView"
        view.backgroundColor = .systemBackground
        setupViews()
    }

    private func setupViews() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 32
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        let scaleToFillImage = makeImageView(
            systemName: "photo",
            contentMode: .scaleAspectFit,
            size: CGSize(width: 120, height: 120),
            tint: .systemBlue,
            label: "scaleAspectFit"
        )

        let scaleFillImage = makeImageView(
            systemName: "star.fill",
            contentMode: .scaleAspectFill,
            size: CGSize(width: 80, height: 80),
            tint: .systemYellow,
            label: "scaleAspectFill"
        )

        let centerImage = makeImageView(
            systemName: "heart.fill",
            contentMode: .center,
            size: CGSize(width: 80, height: 80),
            tint: .systemRed,
            label: "center"
        )

        [scaleToFillImage, scaleFillImage, centerImage].forEach {
            stack.addArrangedSubview($0)
        }
    }

    private func makeImageView(
        systemName: String,
        contentMode: UIView.ContentMode,
        size: CGSize,
        tint: UIColor,
        label: String
    ) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        container.alignment = .center

        let imageView = UIImageView(image: UIImage(systemName: systemName))
        imageView.contentMode = contentMode
        imageView.tintColor = tint
        imageView.backgroundColor = tint.withAlphaComponent(0.1)
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        imageView.accessibilityLabel = systemName
        imageView.accessibilityIdentifier = "image_\(systemName)"

        let caption = UILabel()
        caption.text = label
        caption.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        caption.textColor = .secondaryLabel

        container.addArrangedSubview(imageView)
        container.addArrangedSubview(caption)
        return container
    }
}
