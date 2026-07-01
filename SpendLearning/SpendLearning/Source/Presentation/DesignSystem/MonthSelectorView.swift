//
//  MonthSelectorView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit

final class MonthSelectorView: UIView {
    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?

    private let previousButton = IconCircleView(symbolName: "chevron.left", size: 34)
    private let nextButton = IconCircleView(symbolName: "chevron.right", size: 34)
    private let titleLabel = UILabel()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setup() {
        [previousButton, titleLabel, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        setupGestures()
        setupTitleLabel()
        setupConstraints()
    }

    private func setupGestures() {
        previousButton.isUserInteractionEnabled = true
        nextButton.isUserInteractionEnabled = true

        let prevTap = UITapGestureRecognizer(target: self, action: #selector(didTapPrevious))
        let nextTap = UITapGestureRecognizer(target: self, action: #selector(didTapNext))
        previousButton.addGestureRecognizer(prevTap)
        nextButton.addGestureRecognizer(nextTap)
    }

    private func setupTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .DesignSystem.primary
        titleLabel.textAlignment = .center
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            previousButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            previousButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            nextButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            heightAnchor.constraint(equalToConstant: 34),
        ])
    }

    func configure(year: Int, month: Int) {
        titleLabel.text = "\(year)년 \(month)월"
    }

    @objc private func didTapPrevious() {
        onPrevious?()
    }

    @objc private func didTapNext() {
        onNext?()
    }
}
