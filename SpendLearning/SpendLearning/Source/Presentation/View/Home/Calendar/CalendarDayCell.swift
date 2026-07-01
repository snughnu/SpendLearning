//
//  CalendarDayCell.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit

final class CalendarDayCell: UICollectionViewCell {

    private let circleView = UIView()
    private let dayLabel = UILabel()
    private let amountLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(day: Int?, amount: Int?, isToday: Bool, isSelected: Bool) {
        guard let day else {
            dayLabel.text = nil
            amountLabel.text = nil
            circleView.backgroundColor = .clear
            circleView.layer.borderWidth = 0
            return
        }

        dayLabel.text = "\(day)"
        amountLabel.text = amount.map { $0.formatted() } ?? " "

        if isToday && isSelected {
            circleView.backgroundColor = .DesignSystem.accent
            circleView.layer.borderWidth = 1.5
            circleView.layer.borderColor = UIColor.DesignSystem.primary.cgColor
            dayLabel.textColor = .DesignSystem.surface
        } else if isToday {
            circleView.backgroundColor = .DesignSystem.accent
            circleView.layer.borderWidth = 0
            dayLabel.textColor = .DesignSystem.surface
        } else if isSelected {
            circleView.backgroundColor = .clear
            circleView.layer.borderWidth = 1.5
            circleView.layer.borderColor = UIColor.DesignSystem.primary.cgColor
            dayLabel.textColor = .DesignSystem.primary
        } else {
            circleView.backgroundColor = .clear
            circleView.layer.borderWidth = 0
            dayLabel.textColor = .DesignSystem.primary
        }

        amountLabel.textColor = isSelected ? .DesignSystem.accent : .DesignSystem.subtitle
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = nil
        amountLabel.text = " "
        circleView.backgroundColor = .clear
        circleView.layer.borderWidth = 0
        dayLabel.textColor = .DesignSystem.primary
    }
}

// MARK: - Helper
private extension CalendarDayCell {

    func setup() {
        let circleViewSize: CGFloat = 27
        circleView.layer.cornerRadius = circleViewSize / 2
        circleView.translatesAutoresizingMaskIntoConstraints = false

        dayLabel.font = .systemFont(ofSize: 12.5, weight: .bold)
        dayLabel.textAlignment = .center
        dayLabel.translatesAutoresizingMaskIntoConstraints = false

        amountLabel.font = .systemFont(ofSize: 8.5, weight: .bold)
        amountLabel.textAlignment = .center
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(circleView)
        contentView.addSubview(dayLabel)
        contentView.addSubview(amountLabel)

        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            circleView.widthAnchor.constraint(equalToConstant: circleViewSize),
            circleView.heightAnchor.constraint(equalToConstant: circleViewSize),

            dayLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),

            amountLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 2),
            amountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
}
