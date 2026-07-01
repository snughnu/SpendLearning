//
//  CategoryItemView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit

final class CategoryItemView: UIView {
    var onTap: (() -> Void)?

    private let iconView: IconCircleView
    private let titleLabel = UILabel()

    private var isSelected: Bool = false {
        didSet { updateAppearance() }
    }

    init(symbolName: String, title: String) {
        self.iconView = IconCircleView(symbolName: symbolName, size: 46)
        super.init(frame: .zero)
        setup(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ selected: Bool) {
        isSelected = selected
    }

    func update(symbolName: String, title: String) {
        iconView.update(symbolName: symbolName)
        titleLabel.text = title
    }
}

// MARK: - Helper
private extension CategoryItemView {

    func setup(title: String) {
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = .DesignSystem.primary
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    func updateAppearance() {
        iconView.backgroundColor = isSelected ? .DesignSystem.primary : .DesignSystem.secondary
        titleLabel.textColor = isSelected ? .DesignSystem.primary : .DesignSystem.subtitle
    }

    @objc func didTap() {
        onTap?()
    }
}
