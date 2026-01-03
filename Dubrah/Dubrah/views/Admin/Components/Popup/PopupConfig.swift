//
//  PopupConfig.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

// MARK: - Text Field Model (for forms)
struct PopupTextField {
    let placeholder: String
    let text: String?
    let isSecure: Bool

    init(
        placeholder: String,
        text: String? = nil,
        isSecure: Bool = false
    ) {
        self.placeholder = placeholder
        self.text = text
        self.isSecure = isSecure
    }
}

// MARK: - Popup Config
struct PopupConfig {

    // MARK: - Text
    let title: String
    let message: String?

    // MARK: - Buttons
    let primaryTitle: String
    let secondaryTitle: String?

    let primaryAction: (() -> Void)?
    let secondaryAction: (() -> Void)?

    // MARK: - Styling
    let primaryColor: UIColor
    let secondaryColor: UIColor
    let primaryTextColor: UIColor
    let secondaryTextColor: UIColor
    let buttonCornerRadius: CGFloat
    let secondaryHasBorder: Bool

    // MARK: - Dynamic Content
    let buildContent: ((UIStackView) -> Void)?

    // MARK: - Base Initializer
    init(
        title: String,
        message: String? = nil,
        primaryTitle: String,
        secondaryTitle: String? = nil,
        primaryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil,
        primaryColor: UIColor = UIColor(named: "PrimaryBlue") ?? .systemBlue,
        secondaryColor: UIColor = .clear,
        primaryTextColor: UIColor = .white,
        secondaryTextColor: UIColor = UIColor(named: "PrimaryBlue") ?? .systemBlue,
        buttonCornerRadius: CGFloat = 12,
        secondaryHasBorder: Bool = true,
        buildContent: ((UIStackView) -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryTitle = primaryTitle
        self.secondaryTitle = secondaryTitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.buttonCornerRadius = buttonCornerRadius
        self.secondaryHasBorder = secondaryHasBorder
        self.buildContent = buildContent
    }

    // MARK: - CONFIRM POPUP
    static func confirm(
        title: String,
        message: String,
        confirmTitle: String,
        cancelTitle: String,
        onConfirm: (() -> Void)?,
        onCancel: (() -> Void)? = nil
    ) -> PopupConfig {
        PopupConfig(
            title: title,
            message: message,
            primaryTitle: confirmTitle,
            secondaryTitle: cancelTitle,
            primaryAction: onConfirm,
            secondaryAction: onCancel
        )
    }

    // MARK: - SUSPENSION POPUP
    static func suspension(
        title: String,
        message: String,
        options: [String],
        onConfirm: @escaping (String) -> Void,
        onCancel: (() -> Void)? = nil
    ) -> PopupConfig {

        var selectedOption = options.first ?? ""

        return PopupConfig(
            title: title,
            message: message,
            primaryTitle: "Suspend",
            secondaryTitle: "Cancel",
            primaryAction: {
                onConfirm(selectedOption)
            },
            secondaryAction: onCancel,
            buildContent: { stack in
                options.forEach { option in
                    let button = UIButton(type: .system)
                    button.setTitle(option, for: .normal)
                    button.contentHorizontalAlignment = .left
                    button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)

                    button.addAction(
                        UIAction { _ in
                            selectedOption = option
                        },
                        for: .touchUpInside
                    )

                    stack.addArrangedSubview(button)
                }
            }
        )
    }

    // MARK: - FORM POPUP (Modify Post / Edit Profile)
    static func form(
        title: String,
        message: String? = nil,
        fields: [PopupTextField],
        confirmTitle: String,
        cancelTitle: String,
        onSubmit: @escaping (_ field1: String, _ field2: String) -> Void,
        onCancel: (() -> Void)? = nil
    ) -> PopupConfig {

        var textFields: [UITextField] = []

        return PopupConfig(
            title: title,
            message: message,
            primaryTitle: confirmTitle,
            secondaryTitle: cancelTitle,
            primaryAction: {
                let first = textFields.indices.contains(0)
                    ? (textFields[0].text ?? "")
                    : ""

                let second = textFields.indices.contains(1)
                    ? (textFields[1].text ?? "")
                    : ""

                onSubmit(first, second)
            },
            secondaryAction: onCancel,
            buildContent: { stack in
                textFields.removeAll()

                fields.forEach { field in
                    let tf = UITextField()
                    tf.placeholder = field.placeholder
                    tf.text = field.text
                    tf.isSecureTextEntry = field.isSecure
                    tf.borderStyle = .roundedRect
                    tf.heightAnchor.constraint(equalToConstant: 44).isActive = true

                    textFields.append(tf)
                    stack.addArrangedSubview(tf)
                }
            }
        )
    }
}
