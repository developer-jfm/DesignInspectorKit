import UIKit

/// Demonstrates inspector on `UIImageView` components.
///
/// Three image views are shown, each with a different `contentMode`.
/// Inspect them to see: imageName, intrinsicContentSize, renderedSize, contentMode, tintColor.
final class ImageExampleViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIImageView"
        view.backgroundColor = .systemBackground
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        // Vertical stack centered on screen holding all image examples.
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

        // MARK: scaleAspectFit — image fits inside bounds, preserving ratio
        let scaleToFillImage = makeImageView(
            systemName: "photo",
            contentMode: .scaleAspectFit,
            size: CGSize(width: 120, height: 120),
            tint: .systemBlue,
            label: "scaleAspectFit"
        )

        // MARK: scaleAspectFill — image fills bounds, may be clipped
        let scaleFillImage = makeImageView(
            systemName: "star.fill",
            contentMode: .scaleAspectFill,
            size: CGSize(width: 80, height: 80),
            tint: .systemYellow,
            label: "scaleAspectFill"
        )

        // MARK: center — image drawn at its natural size, centered in bounds
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

    // MARK: - Helpers

    /// Builds a labeled image view container for the given SF Symbol.
    /// - Parameters:
    ///   - systemName: SF Symbol name to use as the image source.
    ///   - contentMode: The `UIView.ContentMode` to apply.
    ///   - size: Fixed width/height for the image view.
    ///   - tint: Tint color for the symbol and background wash.
    ///   - label: Caption text shown below the image view.
    private func makeImageView(
        systemName: String,
        contentMode: UIView.ContentMode,
        size: CGSize,
        tint: UIColor,
        label: String
    ) -> UIView {
        // Vertical container: image on top, caption below.
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

        // Caption showing the contentMode name for quick reference.
        let caption = UILabel()
        caption.text = label
        caption.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        caption.textColor = .secondaryLabel

        container.addArrangedSubview(imageView)
        container.addArrangedSubview(caption)
        return container
    }
}
