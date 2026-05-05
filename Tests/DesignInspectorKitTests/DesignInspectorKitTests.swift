import Testing
import UIKit
@testable import DesignInspectorKit

// MARK: - UIColor+Hex

@Test func hexString_opaque_returns6Chars() {
    let color = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    #expect(color.hexString == "FF0000")
}

@Test func hexString_transparent_returns8Chars() {
    let color = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
    #expect(color.hexString.count == 8)
    #expect(color.hexString.hasPrefix("FF0000"))
}

@Test func hexString_white_returnsFFFFFF() {
    #expect(UIColor.white.hexString == "FFFFFF")
}

@Test func hexString_black_returns000000() {
    #expect(UIColor.black.hexString == "000000")
}

@Test func initHexString_6chars_parsesCorrectly() {
    let color = UIColor(hexString: "FF0000")
    #expect(color != nil)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    color?.getRed(&r, green: &g, blue: &b, alpha: &a)
    #expect(r == 1.0)
    #expect(g == 0.0)
    #expect(b == 0.0)
    #expect(a == 1.0)
}

@Test func initHexString_withHash_parsesCorrectly() {
    let color = UIColor(hexString: "#00FF00")
    #expect(color != nil)
}

@Test func initHexString_invalid_returnsNil() {
    let color = UIColor(hexString: "ZZZZZZ")
    #expect(color == nil)
}

@Test func isLight_whiteIsLight() {
    #expect(UIColor.white.isLight == true)
}

@Test func isLight_blackIsNotLight() {
    #expect(UIColor.black.isLight == false)
}

// MARK: - ConstraintInfo

@Test func constraintInfo_description_format() {
    let info = ConstraintInfo(
        attribute: "leading",
        relation: "==",
        constant: 16,
        multiplier: 1,
        priority: 1000,
        isActive: true
    )
    #expect(info.description == "leading == 16.0 @ 1000")
}

@Test func constraintInfo_isActive() {
    let info = ConstraintInfo(attribute: "width", relation: "==", constant: 100, multiplier: 1, priority: 750, isActive: false)
    #expect(info.isActive == false)
}

// MARK: - ViewHierarchyInspector

@Test @MainActor func inspector_inspectSingle_returnsCorrectClassName() {
    let view = UILabel()
    view.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(view)
    #expect(info.className == "UILabel")
}

@Test @MainActor func inspector_inspectSingle_returnsCorrectFrame() {
    let view = UIView()
    view.frame = CGRect(x: 10, y: 20, width: 80, height: 40)
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(view)
    #expect(info.frame == CGRect(x: 10, y: 20, width: 80, height: 40))
}

@Test @MainActor func inspector_inspect_countsSubviews() {
    let root = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    root.addSubview(UIView(frame: .zero))
    root.addSubview(UIView(frame: .zero))
    let inspector = ViewHierarchyInspector(configuration: .default)
    let results = inspector.inspect(root)
    #expect(results.count == 3)
}

@Test @MainActor func inspector_depth_isCorrect() {
    let root = UIView(frame: .zero)
    let child = UIView(frame: .zero)
    let grandchild = UIView(frame: .zero)
    root.addSubview(child)
    child.addSubview(grandchild)
    let inspector = ViewHierarchyInspector(configuration: .default)
    let results = inspector.inspect(root)
    #expect(results[0].depth == 0)
    #expect(results[1].depth == 1)
    #expect(results[2].depth == 2)
}

@Test @MainActor func inspector_label_extractsText() {
    let label = UILabel()
    label.text = "Hello"
    label.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(label)
    #expect(info.text == "Hello")
}

@Test @MainActor func inspector_label_extractsFont() {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 18)
    label.frame = .zero
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(label)
    #expect(info.font?.pointSize == 18)
}

@Test @MainActor func inspector_alpha_captured() {
    let view = UIView(frame: .zero)
    view.alpha = 0.5
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(view)
    #expect(info.alpha == 0.5)
}

@Test @MainActor func inspector_cornerRadius_captured() {
    let view = UIView(frame: .zero)
    view.layer.cornerRadius = 8
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(view)
    #expect(info.cornerRadius == 8)
}

// MARK: - UIView+Inspector

@Test @MainActor func spacingToSiblingAbove_returnsCorrectValue() {
    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    let top = UIView(frame: CGRect(x: 0, y: 10, width: 100, height: 40))
    let bottom = UIView(frame: CGRect(x: 0, y: 70, width: 100, height: 40))
    parent.addSubview(top)
    parent.addSubview(bottom)
    #expect(bottom.spacingToSiblingAbove == 20)
}

@Test @MainActor func spacingToSiblingBelow_returnsCorrectValue() {
    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    let top = UIView(frame: CGRect(x: 0, y: 10, width: 100, height: 40))
    let bottom = UIView(frame: CGRect(x: 0, y: 70, width: 100, height: 40))
    parent.addSubview(top)
    parent.addSubview(bottom)
    #expect(top.spacingToSiblingBelow == 20)
}

@Test @MainActor func spacingToSuperView_returnsCorrectInsets() {
    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    let child = UIView(frame: CGRect(x: 10, y: 20, width: 80, height: 60))
    parent.addSubview(child)
    let insets = child.spacingToSuperView
    #expect(insets?.top == 20)
    #expect(insets?.left == 10)
    #expect(insets?.bottom == 120)
    #expect(insets?.right == 110)
}

@Test @MainActor func allSubviews_returnsAllDescendants() {
    let root = UIView(frame: .zero)
    let child = UIView(frame: .zero)
    let grandchild = UIView(frame: .zero)
    root.addSubview(child)
    child.addSubview(grandchild)
    #expect(root.allSubviews().count == 2)
}

@Test @MainActor func spacingToSiblingLeft_returnsCorrectValue() {
    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    let left = UIView(frame: CGRect(x: 10, y: 0, width: 40, height: 100))
    let right = UIView(frame: CGRect(x: 70, y: 0, width: 40, height: 100))
    parent.addSubview(left)
    parent.addSubview(right)
    #expect(right.spacingToSiblingLeft == 20)
}

@Test @MainActor func spacingToSiblingRight_returnsCorrectValue() {
    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    let left = UIView(frame: CGRect(x: 10, y: 0, width: 40, height: 100))
    let right = UIView(frame: CGRect(x: 70, y: 0, width: 40, height: 100))
    parent.addSubview(left)
    parent.addSubview(right)
    #expect(left.spacingToSiblingRight == 20)
}

@Test @MainActor func spacingToSiblingAbove_noSibling_returnsNil() {
    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    let only = UIView(frame: CGRect(x: 0, y: 50, width: 100, height: 40))
    parent.addSubview(only)
    #expect(only.spacingToSiblingAbove == nil)
}

@Test @MainActor func spacingToSuperView_noSuperView_returnsNil() {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    #expect(view.spacingToSuperView == nil)
}

// MARK: - UIStackView inspection

@Test @MainActor func inspector_stackView_extractsAxis() {
    let stack = UIStackView(frame: .zero)
    stack.axis = .horizontal
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(stack)
    #expect(info.stackAxis == .horizontal)
}

@Test @MainActor func inspector_stackView_extractsSpacing() {
    let stack = UIStackView(frame: .zero)
    stack.spacing = 12
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(stack)
    #expect(info.spacing == 12)
}

@Test @MainActor func inspector_stackView_extractsDistribution() {
    let stack = UIStackView(frame: .zero)
    stack.distribution = .fillEqually
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(stack)
    #expect(info.stackDistribution == .fillEqually)
}

@Test @MainActor func inspector_stackView_extractsAlignment() {
    let stack = UIStackView(frame: .zero)
    stack.alignment = .center
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(stack)
    #expect(info.stackAlignment == .center)
}

// MARK: - UISwitch inspection

@Test @MainActor func inspector_switch_extractsIsOn() {
    let sw = UISwitch(frame: .zero)
    sw.isOn = true
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(sw)
    #expect(info.switchIsOn == true)
}

@Test @MainActor func inspector_switch_extractsIsOff() {
    let sw = UISwitch(frame: .zero)
    sw.isOn = false
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(sw)
    #expect(info.switchIsOn == false)
}

// MARK: - UISlider inspection

@Test @MainActor func inspector_slider_extractsValue() {
    let slider = UISlider(frame: .zero)
    slider.minimumValue = 0
    slider.maximumValue = 100
    slider.value = 42
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(slider)
    #expect(info.sliderValue == 42)
    #expect(info.sliderMinValue == 0)
    #expect(info.sliderMaxValue == 100)
}

// MARK: - UIProgressView inspection

@Test @MainActor func inspector_progressView_extractsProgress() {
    let progress = UIProgressView(frame: .zero)
    progress.progress = 0.75
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(progress)
    #expect(info.progressValue == 0.75)
}

// MARK: - UIScrollView inspection

@Test @MainActor func inspector_scrollView_extractsContentSize() {
    let scroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    scroll.contentSize = CGSize(width: 400, height: 800)
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(scroll)
    #expect(info.scrollContentSize == CGSize(width: 400, height: 800))
}

@Test @MainActor func inspector_scrollView_pagingEnabled() {
    let scroll = UIScrollView(frame: .zero)
    scroll.isPagingEnabled = true
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(scroll)
    #expect(info.scrollIsPagingEnabled == true)
}

// MARK: - UITextField inspection

@Test @MainActor func inspector_textField_extractsText() {
    let field = UITextField(frame: .zero)
    field.text = "test input"
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(field)
    #expect(info.text == "test input")
}

@Test @MainActor func inspector_textField_emptyText_showsPlaceholder() {
    let field = UITextField(frame: .zero)
    field.text = ""
    field.placeholder = "Enter email"
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(field)
    #expect(info.text == "Enter email")
}

// MARK: - UIButton inspection

@Test @MainActor func inspector_button_extractsTitle() {
    let button = UIButton(type: .system)
    button.setTitle("Tap me", for: .normal)
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(button)
    #expect(info.text == "Tap me")
}

// MARK: - Border & tint

@Test @MainActor func inspector_borderWidth_captured() {
    let view = UIView(frame: .zero)
    view.layer.borderWidth = 2
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(view)
    #expect(info.borderWidth == 2)
}

@Test @MainActor func inspector_tintColor_captured() {
    let view = UIView(frame: .zero)
    view.tintColor = .systemRed
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(view)
    #expect(info.tintColor != nil)
}

// MARK: - UIImageView inspection

@Test @MainActor func inspector_imageView_extractsSFSymbolName() {
    let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle"))
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(imageView)
    #expect(info.imageName == "checkmark.circle")
}

@Test @MainActor func inspector_imageView_extractsImageSize() {
    let imageView = UIImageView(image: UIImage(systemName: "star"))
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(imageView)
    #expect(info.imageSize != nil)
}

@Test @MainActor func inspector_imageView_extractsContentMode() {
    let imageView = UIImageView(image: UIImage(systemName: "star"))
    imageView.contentMode = .scaleAspectFit
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(imageView)
    #expect(info.contentMode == .scaleAspectFit)
}

@Test @MainActor func inspector_plainView_hasNoImageName() {
    let view = UIView(frame: .zero)
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(view)
    #expect(info.imageName == nil)
    #expect(info.imageSize == nil)
}

// MARK: - Non-UIView does not bleed into wrong component

@Test @MainActor func inspector_plainView_hasNoStackAxis() {
    let view = UIView(frame: .zero)
    let inspector = ViewHierarchyInspector(configuration: .default)
    let info = inspector.inspectSingle(view)
    #expect(info.stackAxis == nil)
    #expect(info.switchIsOn == nil)
    #expect(info.sliderValue == nil)
    #expect(info.progressValue == nil)
}
