//
//  CalendarWeekdayHeader.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit

final class CalendarWeekdayHeader: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helper
private extension CalendarWeekdayHeader {

    func setup() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        ["일", "월", "화", "수", "목", "금", "토"].enumerated().forEach { index, day in
            let label = UILabel()
            label.text = day
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            label.textColor = index == 0 ? .DesignSystem.accent : .DesignSystem.subtitle
            label.textAlignment = .center
            stack.addArrangedSubview(label)
        }
    }
}
