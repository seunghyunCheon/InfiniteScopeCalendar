//
//  ViewController.swift
//  InfiniteCalendarScope
//
//  Created by Brody on 2023/08/20.
//

import UIKit

enum Section: Hashable {
    case main
}

class ViewController: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.isScrollEnabled = true
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth((1.0/7.0)), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight((1.0/6.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)

        let groupSize2 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight((1.0)))
        let group2 = NSCollectionLayoutGroup.vertical(layoutSize: groupSize2, repeatingSubitem: group, count: 6)
        let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group2)
        section.orthogonalScrollingBehavior = .groupPaging

        // 현재 문제는 point가 week으로 변경한 뒤에는 초기화 된다.
        section.visibleItemsInvalidationHandler = { [weak self] _, point, _ in
//            self?.changeMonthLabel(point)
            print(point)
            // 현재 point + width / 2 보다 크다면 다음월로 업데이트
            // 현재 point - width / 2 보다 작다면 이전월로 업데이트
        }

        let layout: UICollectionViewCompositionalLayout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension ViewController: UICollectionViewDelegate {
    
}
