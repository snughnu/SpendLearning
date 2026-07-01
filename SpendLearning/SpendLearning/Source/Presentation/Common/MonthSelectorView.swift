//
//  MonthSelectorView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit

final class MonthSelectorView: UIView {

    // MARK: - Closures
    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?
    var onTitleTapped: (() -> Void)?

    // MARK: - UI
    private let previousButton = IconCircleView(symbolName: "chevron.left", size: 34)
    private let nextButton = IconCircleView(symbolName: "chevron.right", size: 34)
    private let titleStack = UIStackView()
    private let titleLabel = UILabel()
    private let chevronIcon = UIImageView()

    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(year: Int, month: Int) {
        titleLabel.text = "\(year)년 \(month)월"
    }
}

// MARK: - Actions
private extension MonthSelectorView {

    @objc func didTapPrevious() {
        onPrevious?()
    }

    @objc func didTapNext() {
        onNext?()
    }

    @objc func didTapTitle() {
        onTitleTapped?()
    }
}

// MARK: - Helper
private extension MonthSelectorView {

    func setup() {
        [previousButton, titleStack, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        setupTitle()
        setupGestures()
        setupConstraints()
    }

    func setupTitle() {
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .DesignSystem.primary
        titleLabel.textAlignment = .center

        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        chevronIcon.image = UIImage(systemName: "chevron.down", withConfiguration: config)
        chevronIcon.tintColor = .DesignSystem.subtitle
        chevronIcon.contentMode = .scaleAspectFit

        titleStack.axis = .horizontal
        titleStack.alignment = .center
        titleStack.spacing = 4
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(chevronIcon)
    }

    func setupGestures() {
        previousButton.isUserInteractionEnabled = true
        nextButton.isUserInteractionEnabled = true
        titleStack.isUserInteractionEnabled = true

        previousButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPrevious)))
        nextButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapNext)))
        titleStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTitle)))
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            previousButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            previousButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            nextButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            titleStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleStack.centerYAnchor.constraint(equalTo: centerYAnchor),

            heightAnchor.constraint(equalToConstant: 34),
        ])
    }
}
