//
//  ViewController.swift
//  InfiniteCalendarScope
//
//  Created by Brody on 2023/08/20.
//

import UIKit

class Debouncer {
    private let interval: TimeInterval
    private var timer: Timer?

    init(interval: TimeInterval) {
        self.interval = interval
    }

    func debounce(action: @escaping () -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            action()
        }
    }
}

enum Section: Hashable {
    case main
}

class ViewController: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.isScrollEnabled = true
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
        view.scrollIndicatorInsets = UIEdgeInsets(top: -2, left: 0, bottom: 0, right: 4)
        view.contentInset = .zero
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.identifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, DayComponent>!
    
    let dateCalculator = DateCalculator(baseDate: Date())
    
    private var days: [[DayComponent]] = []
    private var baseDate: Date = Date() {
        didSet {
            updateDays()
        }
    }
    
    let debouncer = Debouncer(interval: 0.05)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        days = dateCalculator.getDaysInMonth(for: Date())
        setupCalendarView()
        configureDataSource()
        configureSnapshot()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupCenterXOffset()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        setupCenterXOffset()
        self.collectionView.scrollToItem(at: IndexPath(item: 43, section: 0), at: .bottom, animated: false)
        previousCenterX = 393
    }
    
    private func updateDays() {
        days = dateCalculator.getDaysInMonth(for: baseDate)
    }
    
    func setupCalendarView() {
        self.view.addSubview(self.collectionView)
        
        let safe = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: safe.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
        ])
    }
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, DayComponent>(
            collectionView: self.collectionView
        ) { collectionView, indexPath, item in
            guard let dateCollectionViewCell: CalendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.identifier, for: indexPath) as? CalendarCell else {
                return UICollectionViewCell()
            }
            
            dateCollectionViewCell.configure(item: item)
            return dateCollectionViewCell
        }
    }
    
    func configureSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DayComponent>()
        snapshot.appendSections([.main])
        
        // 월간일 때 snapshot
        
        snapshot.appendItems(days[0], toSection: .main)
        snapshot.appendItems(days[1], toSection: .main)
        snapshot.appendItems(days[2], toSection: .main)
        
        
        // 주간일 때 snapshot
//        snapshot.appendItems(days[0].filter { $0.isIncludeInMonth }, toSection: .main)
//        snapshot.appendItems(days[1].filter { $0.isIncludeInMonth }, toSection: .main)
//        snapshot.appendItems(days[2].filter { $0.isIncludeInMonth }, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    @discardableResult
    private func setupCenterXOffset() -> CGFloat {
        let middleSectionIndex = 1
        let width = view.frame.width * 3
        let middleSectionX = width / 3 * CGFloat(middleSectionIndex)
        collectionView.setContentOffset(CGPoint(x: middleSectionX, y: 0), animated: false)
//        collectionView.contentOffset = CGPoint(x: middleSectionX, y: 0)
//        collectionView.scrollToItem(at: IndexPath(item: 60, section: 0), at: .centeredHorizontally, animated: false)
        return middleSectionX
    }
    
    private var previousTime: TimeInterval = 0
    private var previousCenterX: CGFloat?
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        
        // week scope
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth((1.0/7.0)), heightDimension: .fractionalHeight(1.0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight((1.0/6.0)))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)
//
//        let groupSize2 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight((1.0)))
//        let group2 = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize2, repeatingSubitem: group, count: 1)
//        let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group2)
//        section.orthogonalScrollingBehavior = .paging
//
//        // 현재 문제는 point가 week으로 변경한 뒤에는 초기화 된다.
//        section.visibleItemsInvalidationHandler = { [weak self] _, point, _ in
////            self?.changeMonthLabel(point)
//            print(point)
//        }
//
//        let layout: UICollectionViewCompositionalLayout = UICollectionViewCompositionalLayout(section: section)
//        return layout
        
        // month scope
//        let config = UICollectionViewCompositionalLayoutConfiguration()
//        config.scrollDirection = .horizontal
//        let layouts = UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
//            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth((1.0/7.0)), heightDimension: .fractionalHeight(1.0))
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
//
//            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight((1.0/6.0)))
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)
//
//            let groupSize2 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight((1.0)))
//            let group2 = NSCollectionLayoutGroup.vertical(layoutSize: groupSize2, repeatingSubitem: group, count: 6)
//            let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group2)
//            section.orthogonalScrollingBehavior = .groupPaging
//
//            return section
//        }, configuration: config)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth((1.0/7.0)), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight((1.0/6.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)

        let groupSize2 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight((1.0)))
        let group2 = NSCollectionLayoutGroup.vertical(layoutSize: groupSize2, repeatingSubitem: group, count: 6)
        let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group2)
        section.orthogonalScrollingBehavior = .groupPaging

        section.visibleItemsInvalidationHandler = { [weak self] items , point, env in
            guard let self else { return }
            debouncer.debounce {
                if point.x == 786.0 {
                    print(self.baseDate)
                    var snapshot = self.dataSource.snapshot()
                    snapshot.deleteAllItems()
                    snapshot.appendSections([.main])
                    
                    let nextMonth = self.dateCalculator.calculateNextMonth(by: self.baseDate)
                    self.baseDate = nextMonth
                    
                    // 다음달을 갈때 다음달에 해달하는 days들을 가져오는데 이 떄
                    // 월간일 때 snapshotz
                    snapshot.appendItems(self.days[0], toSection: .main)
                    snapshot.appendItems(self.days[1], toSection: .main)
                    snapshot.appendItems(self.days[2], toSection: .main)

                    DispatchQueue.main.async {
                        self.dataSource.apply(snapshot, animatingDifferences: false)
                    }
                    self.collectionView.scrollToItem(at: IndexPath(item: 42, section: 0), at: .bottom, animated: false)
                } else if point.x == 0 {
                    var snapshot = self.dataSource.snapshot()
                    snapshot.deleteAllItems()
                    snapshot.appendSections([.main])
                    
                    let nextMonth = self.dateCalculator.calculatePreviousMonth(by: self.baseDate)
                    self.baseDate = nextMonth
                    
                    // 다음달을 갈때 다음달에 해달하는 days들을 가져오는데 이 떄
                    // 월간일 때 snapshotz
                    snapshot.appendItems(self.days[0], toSection: .main)
                    snapshot.appendItems(self.days[1], toSection: .main)
                    snapshot.appendItems(self.days[2], toSection: .main)

                    DispatchQueue.main.async {
                        self.dataSource.apply(snapshot, animatingDifferences: false)
                    }
                    self.collectionView.scrollToItem(at: IndexPath(item: 42, section: 0), at: .bottom, animated: false)
                }
            }
        }
        
        let layout: UICollectionViewCompositionalLayout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension ViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("here")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("aa")
    }
}
