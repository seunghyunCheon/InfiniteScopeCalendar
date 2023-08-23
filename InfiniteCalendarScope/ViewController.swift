//
//  ViewController.swift
//  InfiniteCalendarScope
//
//  Created by Brody on 2023/08/20.
//

import UIKit
import Combine

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
    
    lazy var dateCalculator = DateCalculator(baseDate: Date(), coreDataService: coreDataLottoPersistence)
    
    private var days: [DayComponent] = [] {
        didSet {
            updateSnapshot()
        }
    }
    private lazy var baseDate: Date = Date() {
        didSet {
            dateCalculator.fetchDaysInMonth(for: baseDate)
        }
    }
    
    let debouncer = Debouncer(interval: 0.05)
    
    lazy var coreDataLottoPersistence = CoreDataLottoEntityPersistenceService(coreDataPersistenceService: CoreDataPersistenceService.shared)
    
    let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("로또추가", for: .normal)
        button.backgroundColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var cancellables = Set<AnyCancellable>()
    
    var dire: String = "none"
    
    // 맨 처음에 fetch를 한다. 이때 days를 감지하고 있는 곳에서 snapshot을 설정해준다.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCalendarView()
        configureDataSource()
        setupAddButton()
        bind()
        dateCalculator.fetchDaysInMonth(for: Date())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.scrollToItem(at: IndexPath(item: 43, section: 0), at: .bottom, animated: false)
    }
    
    func bind() {
        self.dateCalculator.days
            .sink { days in
                self.days = days
            }
            .store(in: &cancellables)
    }
    private func updateSnapshot() {
        if dire == "right" {
            var snapshot = self.dataSource.snapshot()
            snapshot.deleteAllItems()
            
            snapshot.appendSections([.main])
            snapshot.appendItems(self.days, toSection: .main)

            DispatchQueue.main.async {
                self.dataSource.apply(snapshot, animatingDifferences: false)
                
                self.collectionView.scrollToItem(at: IndexPath(item: 42, section: 0), at: .bottom, animated: false)
            }
            
        } else if dire == "none" {
            var snapshot = NSDiffableDataSourceSnapshot<Section, DayComponent>()
            snapshot.appendSections([.main])
            
            // 월간일 때 snapshot
            
            snapshot.appendItems(days, toSection: .main)
            
            // 주간일 때 snapshot
    //        snapshot.appendItems(days[0].filter { $0.isIncludeInMonth }, toSection: .main)
    //        snapshot.appendItems(days[1].filter { $0.isIncludeInMonth }, toSection: .main)
    //        snapshot.appendItems(days[2].filter { $0.isIncludeInMonth }, toSection: .main)
            dataSource.apply(snapshot)
        }

    }
    
    func setupCalendarView() {
        self.view.addSubview(self.collectionView)
        
        let safe = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: safe.topAnchor),
            self.collectionView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func setupAddButton() {
        self.view.addSubview(self.addButton)
        
        NSLayoutConstraint.activate([
            self.addButton.topAnchor.constraint(equalTo: self.collectionView.bottomAnchor, constant: 10),
            self.addButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        self.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    @objc
    func addButtonTapped() {
        coreDataLottoPersistence.saveGoalAmountEntity(Date())
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
                    self.dire = "right"
                    
                    let nextMonth = self.dateCalculator.calculateNextMonth(by: self.baseDate)
                    self.baseDate = nextMonth
                } else if point.x == 0 {
                    var snapshot = self.dataSource.snapshot()
                    snapshot.deleteAllItems()
                    snapshot.appendSections([.main])
                    
                    let nextMonth = self.dateCalculator.calculatePreviousMonth(by: self.baseDate)
                    self.baseDate = nextMonth
                    
                    // 다음달을 갈때 다음달에 해달하는 days들을 가져오는데 이 떄
                    // 월간일 때 snapshotz
                    snapshot.appendItems(self.days, toSection: .main)

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
