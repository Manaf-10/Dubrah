//
//  PopupConfig.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit


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


struct PopupConfig {

    
    let title: String
    let message: String?

    
    let primaryTitle: String
    let secondaryTitle: String?

    let primaryAction: (() -> Void)?
    let secondaryAction: (() -> Void)?

    
    let primaryColor: UIColor
    let secondaryColor: UIColor
    let primaryTextColor: UIColor
    let secondaryTextColor: UIColor
    let buttonCornerRadius: CGFloat
    let secondaryHasBorder: Bool


    let buildContent: ((UIStackView) -> Void)?

    
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

    
    static func suspension(
        title: String,
        message: String?,
        options: [String],
        onConfirm: @escaping (String) -> Void
    ) -> PopupConfig {
        
        var selectedOption = options.first ?? ""
        
        return PopupConfig(
            title: title,
            message: message,
            primaryTitle: "Suspend",
            secondaryTitle: "Cancel",
            primaryAction: { onConfirm(selectedOption) },
            secondaryAction: nil,
            buildContent: { stackView in
                
                // Radio button group
                let radioGroup = UIStackView()
                radioGroup.axis = .horizontal
                radioGroup.distribution = .fillEqually
                radioGroup.spacing = 8
                radioGroup.translatesAutoresizingMaskIntoConstraints = false
                
                for (index, option) in options.enumerated() {
                    let button = createRadioButton(
                        title: option,
                        isSelected: index == 0,
                        tag: index
                    )
                    
                    button.addAction(UIAction { _ in
                        // Deselect all
                        radioGroup.arrangedSubviews.forEach { view in
                            if let btn = view as? UIButton {
                                btn.isSelected = false
                                btn.backgroundColor = .white
                                btn.layer.borderWidth = 1
                                btn.layer.borderColor = UIColor.lightGray.cgColor
                                btn.setTitleColor(.darkGray, for: .normal)
                            }
                        }
                        
                        // Select tapped button
                        button.isSelected = true
                        button.backgroundColor = UIColor(named: "PrimaryBlue")
                        button.layer.borderWidth = 0
                        button.setTitleColor(.white, for: .normal)
                        
                        selectedOption = option
                    }, for: .touchUpInside)
                    
                    radioGroup.addArrangedSubview(button)
                }
                
                stackView.addArrangedSubview(radioGroup)
                
                NSLayoutConstraint.activate([
                    radioGroup.heightAnchor.constraint(equalToConstant: 100)
                ])
            }
        )
    }

    // Helper method to create radio buttons
    private static func createRadioButton(title: String, isSelected: Bool, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.isSelected = isSelected
        
        // Parse title to extract number and unit
        let components = title.split(separator: " ")
        let number = String(components.first ?? "")
        let unit = components.count > 1 ? String(components.last ?? "") : ""
        
        // Create attributed title
        let attributedTitle = NSMutableAttributedString()
        
        // Number (large)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: isSelected ? UIColor.white : UIColor.darkGray
        ]
        attributedTitle.append(NSAttributedString(string: number + "\n", attributes: numberAttributes))
        
        // Unit (small)
        let unitAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: isSelected ? UIColor.white : UIColor.darkGray
        ]
        attributedTitle.append(NSAttributedString(string: unit, attributes: unitAttributes))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        
        // Style
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        
        if isSelected {
            button.backgroundColor = UIColor(named: "PrimaryBlue")
            button.layer.borderWidth = 0
        } else {
            button.backgroundColor = .white
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        return button
    }

    
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
