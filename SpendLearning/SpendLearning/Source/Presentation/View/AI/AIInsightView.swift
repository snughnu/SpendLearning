//
//  AIInsightView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/4/26.
//

import UIKit

enum AIInsightType {
    case abnormal
    case forecast
    case unrecorded

    var title: String {
        switch self {
        case .abnormal: return "이상 지출 감지"
        case .forecast: return "지출 예고"
        case .unrecorded: return "미기록 감지"
        }
    }
}

struct AIInsightItem {
    let type: AIInsightType
    let description: String
}

final class AIInsightView: UIView {

    // MARK: - UI
    private let headerView = InsightHeaderView()
    private let bodyView = InsightBodyView()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(items: [AIInsightItem]) {
        bodyView.configure(items: items)
    }
}

// MARK: - Helper
private extension AIInsightView {

    func setup() {
        backgroundColor = .DesignSystem.surface
        layer.cornerRadius = 16
        clipsToBounds = true

        setupSubviews()
        setupConstraints()
    }

    func setupSubviews() {
        [headerView, bodyView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            bodyView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            bodyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bodyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bodyView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

// MARK: - InsightHeaderView
private final class InsightHeaderView: UIView {

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .DesignSystem.accent

        titleLabel.text = "인사이트"
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
        ])
    }
}

// MARK: - InsightBodyView
private final class InsightBodyView: UIView {

    private let emptyLabel = UILabel()
    private let abnormalRow = AIInsightItemView()
    private let separator1 = UIView()
    private let forecastRow = AIInsightItemView()
    private let separator2 = UIView()
    private let unrecordedRow = AIInsightItemView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(items: [AIInsightItem]) {
        emptyLabel.isHidden = !items.isEmpty

        let pairs: [(AIInsightType, AIInsightItemView)] = [
            (.abnormal, abnormalRow),
            (.forecast, forecastRow),
            (.unrecorded, unrecordedRow)
        ]

        pairs.forEach { type, row in
            if let item = items.first(where: { $0.type == type }) {
                row.configure(item: item)
                row.isHidden = false
            } else {
                row.isHidden = true
            }
        }
    }

    private func setup() {
        separator1.backgroundColor = .DesignSystem.separator
        separator2.backgroundColor = .DesignSystem.separator

        emptyLabel.text = "아직 패턴을 분석 중이에요"
        emptyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        emptyLabel.textColor = .DesignSystem.subtitle
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true

        [emptyLabel, abnormalRow, separator1,
         forecastRow, separator2, unrecordedRow].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            emptyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            emptyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emptyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            emptyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            abnormalRow.topAnchor.constraint(equalTo: topAnchor),
            abnormalRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            abnormalRow.trailingAnchor.constraint(equalTo: trailingAnchor),

            separator1.topAnchor.constraint(equalTo: abnormalRow.bottomAnchor),
            separator1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            separator1.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            separator1.heightAnchor.constraint(equalToConstant: 0.5),

            forecastRow.topAnchor.constraint(equalTo: separator1.bottomAnchor),
            forecastRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            forecastRow.trailingAnchor.constraint(equalTo: trailingAnchor),

            separator2.topAnchor.constraint(equalTo: forecastRow.bottomAnchor),
            separator2.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            separator2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            separator2.heightAnchor.constraint(equalToConstant: 0.5),

            unrecordedRow.topAnchor.constraint(equalTo: separator2.bottomAnchor),
            unrecordedRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            unrecordedRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            unrecordedRow.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

// MARK: - AIInsightItemView
private final class AIInsightItemView: UIView {

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item: AIInsightItem) {
        titleLabel.text = item.type.title
        descriptionLabel.text = item.description
    }

    private func setup() {
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .DesignSystem.primary

        descriptionLabel.font = .systemFont(ofSize: 12, weight: .regular)
        descriptionLabel.textColor = .DesignSystem.subtitle
        descriptionLabel.numberOfLines = 0

        [titleLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
}
