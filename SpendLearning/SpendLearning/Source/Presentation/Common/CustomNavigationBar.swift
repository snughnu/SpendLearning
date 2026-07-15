//
//  CustomNavigationBar.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import UIKit

final class CustomNavigationBar: UIView {

    // MARK: - Closures
    var onLeftAction: (() -> Void)?
    var onRightAction: (() -> Void)?

    // MARK: - UI
    private let titleLabel = UILabel()
    private let leftButton = UIButton()
    private let rightButton = UIButton()
    private let bottomSeparator = UIView()

    // MARK: - Init
    init(title: String, leftButtonTitle: String, rightButtonTitle: String? = nil) {
        super.init(frame: .zero)
        titleLabel.text = title
        leftButton.setTitle(leftButtonTitle, for: .normal)
        rightButton.setTitle(rightButtonTitle, for: .normal)
        rightButton.isHidden = rightButtonTitle == nil
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateRightButton(title: String) {
        rightButton.setTitle(title, for: .normal)
    }
}

// MARK: - Actions
private extension CustomNavigationBar {

    @objc func didTapLeft() {
        onLeftAction?()
    }

    @objc func didTapRight() {
        onRightAction?()
    }
}

// MARK: - Helper
private extension CustomNavigationBar {

    func setup() {
        setupSubviews()
        setupConstraints()
    }

    func setupSubviews() {
        backgroundColor = .DesignSystem.background

        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .DesignSystem.primary
        titleLabel.textAlignment = .center

        leftButton.setTitleColor(.DesignSystem.primary, for: .normal)
        leftButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        leftButton.addTarget(self, action: #selector(didTapLeft), for: .touchUpInside)

        rightButton.setTitleColor(.DesignSystem.accent, for: .normal)
        rightButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        rightButton.addTarget(self, action: #selector(didTapRight), for: .touchUpInside)

        bottomSeparator.backgroundColor = .DesignSystem.separator

        [titleLabel, leftButton, rightButton, bottomSeparator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),

            leftButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            leftButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            rightButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            bottomSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}
