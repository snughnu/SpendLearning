//
//  AICategoryPredictionView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/4/26.
//

import UIKit

final class AICategoryPredictionView: UIView {

    // MARK: - UI
    private let headerView = HeaderView()
    private let chartView = ChartView()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helper
private extension AICategoryPredictionView {

    func setup() {
        backgroundColor = .DesignSystem.surface
        layer.cornerRadius = 16
        clipsToBounds = true

        setupSubviews()
        setupConstraints()
    }

    func setupSubviews() {
        [headerView, chartView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            chartView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor),
            chartView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
}

// MARK: - HeaderView
private final class HeaderView: UIView {

    private let titleLabel = UILabel()
    private let legendContainerView = UIView()
    private let actualLegend = LegendView(title: "실제", color: .DesignSystem.primary)
    private let predictedLegend = LegendView(title: "예측", color: .DesignSystem.secondary)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .DesignSystem.accent

        titleLabel.text = "카테고리별 실제 vs 예측"
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .white

        legendContainerView.backgroundColor = .DesignSystem.surface
        legendContainerView.layer.cornerRadius = 8

        [actualLegend, predictedLegend].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            legendContainerView.addSubview($0)
        }

        [titleLabel, legendContainerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),

            legendContainerView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            legendContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            actualLegend.topAnchor.constraint(equalTo: legendContainerView.topAnchor, constant: 6),
            actualLegend.leadingAnchor.constraint(equalTo: legendContainerView.leadingAnchor, constant: 8),
            actualLegend.bottomAnchor.constraint(equalTo: legendContainerView.bottomAnchor, constant: -6),

            predictedLegend.centerYAnchor.constraint(equalTo: actualLegend.centerYAnchor),
            predictedLegend.leadingAnchor.constraint(equalTo: actualLegend.trailingAnchor, constant: 10),
            predictedLegend.trailingAnchor.constraint(equalTo: legendContainerView.trailingAnchor, constant: -8),
        ])
    }
}

// MARK: - ChartView
private final class ChartView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .DesignSystem.background
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - LegendView
private final class LegendView: UIView {

    private let colorBox = UIView()
    private let label = UILabel()

    init(title: String, color: UIColor) {
        super.init(frame: .zero)
        colorBox.backgroundColor = color
        colorBox.layer.cornerRadius = 3

        label.text = title
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .DesignSystem.primary

        [colorBox, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            colorBox.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorBox.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorBox.widthAnchor.constraint(equalToConstant: 12),
            colorBox.heightAnchor.constraint(equalToConstant: 12),

            label.leadingAnchor.constraint(equalTo: colorBox.trailingAnchor, constant: 4),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
