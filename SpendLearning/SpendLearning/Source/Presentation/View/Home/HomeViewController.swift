//
//  HomeViewController.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {

    // MARK: - UI
    private let monthSelectorView = MonthSelectorView()
    private let aiCommentContainerView = UIView()
    private let aiCommentLabel = UILabel()
    private let totalTitleLabel = UILabel()
    private let totalAmountLabel = UILabel()
    private let todayButton = UIButton()
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    private let calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let expenseDateLabel = UILabel()
    private let expenseTotalLabel = UILabel()
    private let expenseCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let fabButton = UIButton()

    // MARK: - Constraints
    private var calendarHeightConstraint: NSLayoutConstraint!
    private var expenseCollectionHeightConstraint: NSLayoutConstraint!

    // MARK: - Cell Registration
    private let calendarCellRegistration = UICollectionView.CellRegistration<CalendarDayCell, (CalendarDay, Bool)> {
        cell, indexPath, item in
        let (day, isSelected) = item
        cell.configure(day: day.date.map { Calendar.current.component(.day, from: $0) },
                       amount: day.amount,
                       isToday: day.isToday,
                       isSelected: isSelected)
    }
    private let expenseCellRegistration = UICollectionView.CellRegistration<ExpenseCell, Expense> {
        cell, indexPath, expense in
        cell.configure(category: expense.category, memo: expense.memo, amount: expense.amount)
    }
    private let weekdayHeaderRegistration = UICollectionView.SupplementaryRegistration<CalendarWeekdayHeader>(
        elementKind: UICollectionView.elementKindSectionHeader
    ) { _, _, _ in }

    // MARK: - Properties
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    private let expenseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 지출내역"
        return formatter
    }()

    // MARK: - Init
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
}

// MARK: - Bind
private extension HomeViewController {

    func bind() {
        viewModel.$currentYear
            .combineLatest(viewModel.$currentMonth)
            .sink { [weak self] year, month in
                self?.monthSelectorView.configure(year: year, month: month)
            }
            .store(in: &cancellables)

        viewModel.$aiComment
            .sink { [weak self] comment in
                self?.aiCommentLabel.text = comment
            }
            .store(in: &cancellables)

        viewModel.$totalAmount
            .sink { [weak self] amount in
                self?.totalAmountLabel.text = "\(amount.formatted())원"
            }
            .store(in: &cancellables)

        viewModel.$calendarDays
            .sink { [weak self] _ in
                self?.calendarCollectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$calendarWeekCount
            .sink { [weak self] weeks in
                guard let self else { return }
                // 36: 요일 헤더, 47: row 높이, 22: 상하 contentInset
                self.calendarHeightConstraint.constant = 36 + 47 * CGFloat(weeks) + 22
                UIView.animate(withDuration: 0.2) { self.view.layoutIfNeeded() }
            }
            .store(in: &cancellables)

        viewModel.$selectedDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                guard let self else { return }
                self.expenseDateLabel.text = self.expenseDateFormatter.string(from: date)
                self.calendarCollectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$selectedDayExpenses
            .sink { [weak self] expenses in
                guard let self else { return }
                self.expenseCollectionHeightConstraint.constant = CGFloat(expenses.count) * 58
                self.expenseCollectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$selectedDayTotal
            .sink { [weak self] total in
                self?.expenseTotalLabel.text = "총 \(total.formatted())원"
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView === calendarCollectionView {
            return viewModel.calendarDays.count
        }
        if collectionView === expenseCollectionView {
            return viewModel.selectedDayExpenses.count
        }
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView === calendarCollectionView {
            let day = viewModel.calendarDays[indexPath.item]
            let isSelected = day.date.map {
                Calendar.current.isDate($0, inSameDayAs: viewModel.selectedDate)
            } ?? false
            return collectionView.dequeueConfiguredReusableCell(
                using: calendarCellRegistration, for: indexPath, item: (day, isSelected)
            )
        }
        if collectionView === expenseCollectionView {
            let expense = viewModel.selectedDayExpenses[indexPath.item]
            return collectionView.dequeueConfiguredReusableCell(
                using: expenseCellRegistration, for: indexPath, item: expense
            )
        }
        return UICollectionViewCell()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard collectionView === calendarCollectionView else {
            return UICollectionReusableView()
        }
        return collectionView.dequeueConfiguredReusableSupplementary(
            using: weekdayHeaderRegistration, for: indexPath
        )
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard collectionView === calendarCollectionView else { return }
        let day = viewModel.calendarDays[indexPath.item]
        guard let date = day.date else { return }
        viewModel.didSelectDate(date)
    }
}

// MARK: - Helper
private extension HomeViewController {

    func setup() {
        view.backgroundColor = .DesignSystem.background
        setupSubviews()
        setupLabels()
        setupTodayButton()
        setupConstraints()
        setupCalendarCollectionView()
        setupExpenseCollectionView()
        setupFAB()
        setupMonthSelector()
    }

    func setupSubviews() {
        [monthSelectorView, aiCommentContainerView, totalTitleLabel,
         totalAmountLabel, todayButton, scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        aiCommentLabel.translatesAutoresizingMaskIntoConstraints = false
        aiCommentContainerView.addSubview(aiCommentLabel)

        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(scrollContentView)
        scrollView.showsVerticalScrollIndicator = false

        [calendarCollectionView, expenseDateLabel,
         expenseTotalLabel, expenseCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollContentView.addSubview($0)
        }

        fabButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fabButton)
    }

    func setupLabels() {
        aiCommentContainerView.backgroundColor = .DesignSystem.secondary
        aiCommentContainerView.layer.cornerRadius = 16

        aiCommentLabel.font = .systemFont(ofSize: 13.5, weight: .semibold)
        aiCommentLabel.textColor = .DesignSystem.primary
        aiCommentLabel.numberOfLines = 0

        totalTitleLabel.text = "이번 달 총 지출"
        totalTitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        totalTitleLabel.textColor = .DesignSystem.subtitle

        totalAmountLabel.font = .systemFont(ofSize: 32, weight: .heavy)
        totalAmountLabel.textColor = .DesignSystem.primary

        expenseDateLabel.font = .systemFont(ofSize: 16, weight: .bold)
        expenseDateLabel.textColor = .DesignSystem.primary

        expenseTotalLabel.font = .systemFont(ofSize: 12.5, weight: .semibold)
        expenseTotalLabel.textColor = .DesignSystem.subtitle
    }

    func setupTodayButton() {
        var config = UIButton.Configuration.bordered()
        config.title = "오늘"
        config.baseForegroundColor = .DesignSystem.subtitle
        config.baseBackgroundColor = .DesignSystem.secondary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            return a
        }
        todayButton.configuration = config
        todayButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.didSelectToday()
        }, for: .touchUpInside)
    }

    func setupConstraints() {
        calendarHeightConstraint = calendarCollectionView.heightAnchor.constraint(equalToConstant: 36 + 47 * 6 + 22)
        expenseCollectionHeightConstraint = expenseCollectionView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            monthSelectorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            monthSelectorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            monthSelectorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            aiCommentContainerView.topAnchor.constraint(equalTo: monthSelectorView.bottomAnchor, constant: 16),
            aiCommentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            aiCommentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            aiCommentLabel.topAnchor.constraint(equalTo: aiCommentContainerView.topAnchor, constant: 13),
            aiCommentLabel.bottomAnchor.constraint(equalTo: aiCommentContainerView.bottomAnchor, constant: -13),
            aiCommentLabel.leadingAnchor.constraint(equalTo: aiCommentContainerView.leadingAnchor, constant: 15),
            aiCommentLabel.trailingAnchor.constraint(equalTo: aiCommentContainerView.trailingAnchor, constant: -15),

            totalTitleLabel.topAnchor.constraint(equalTo: aiCommentContainerView.bottomAnchor, constant: 16),
            totalTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            totalAmountLabel.topAnchor.constraint(equalTo: totalTitleLabel.bottomAnchor, constant: 2),
            totalAmountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            totalAmountLabel.trailingAnchor.constraint(lessThanOrEqualTo: todayButton.leadingAnchor, constant: -8),

            todayButton.centerYAnchor.constraint(equalTo: totalAmountLabel.centerYAnchor),
            todayButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            scrollView.topAnchor.constraint(equalTo: totalAmountLabel.bottomAnchor, constant: 18),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            calendarCollectionView.topAnchor.constraint(equalTo: scrollContentView.topAnchor),
            calendarCollectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            calendarCollectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            calendarHeightConstraint,

            expenseDateLabel.topAnchor.constraint(equalTo: calendarCollectionView.bottomAnchor, constant: 14),
            expenseDateLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),

            expenseTotalLabel.centerYAnchor.constraint(equalTo: expenseDateLabel.centerYAnchor),
            expenseTotalLabel.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),

            expenseCollectionView.topAnchor.constraint(equalTo: expenseDateLabel.bottomAnchor, constant: 10),
            expenseCollectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            expenseCollectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            expenseCollectionView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -20),
            expenseCollectionHeightConstraint,

            fabButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            fabButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            fabButton.widthAnchor.constraint(equalToConstant: 56),
            fabButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }

    func setupCalendarCollectionView() {
        calendarCollectionView.backgroundColor = .DesignSystem.surface
        calendarCollectionView.layer.cornerRadius = 20
        calendarCollectionView.isScrollEnabled = false
        calendarCollectionView.setCollectionViewLayout(makeCalendarLayout(), animated: false)
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
    }

    func setupExpenseCollectionView() {
        expenseCollectionView.backgroundColor = .clear
        expenseCollectionView.isScrollEnabled = false
        expenseCollectionView.setCollectionViewLayout(makeExpenseLayout(), animated: false)
        expenseCollectionView.dataSource = self
    }

    func setupFAB() {
        fabButton.backgroundColor = .DesignSystem.primary
        fabButton.layer.cornerRadius = 28
        fabButton.layer.shadowColor = UIColor.DesignSystem.primary.cgColor
        fabButton.layer.shadowOpacity = 0.4
        fabButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        fabButton.layer.shadowRadius = 12

        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        fabButton.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        fabButton.tintColor = .white
    }

    func setupMonthSelector() {
        monthSelectorView.onPrevious = { [weak self] in
            self?.viewModel.didTapPreviousMonth()
        }
        monthSelectorView.onNext = { [weak self] in
            self?.viewModel.didTapNextMonth()
        }
        monthSelectorView.onTitleTapped = { [weak self] in
            self?.presentMonthYearPicker()
        }
    }

    func makeCalendarLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/7), heightDimension: .absolute(47))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(47))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 10, bottom: 8, trailing: 10)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(36))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]

        return UICollectionViewCompositionalLayout(section: section)
    }

    func makeExpenseLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(58))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(58))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Presentation
private extension HomeViewController {

    func presentMonthYearPicker() {
        let pickerVC = MonthYearPickerViewController(year: viewModel.currentYear, month: viewModel.currentMonth)
        pickerVC.onConfirm = { [weak self] year, month, selectedDay in
            self?.viewModel.didSelectYearMonth(year: year, month: month)
            self?.viewModel.didSelectDate(selectedDay)
        }

        if let sheet = pickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }

        present(pickerVC, animated: true)
    }
}
