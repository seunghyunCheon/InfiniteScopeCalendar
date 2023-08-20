//
//  CalendarCell.swift
//  InfiniteCalendarScope
//
//  Created by Brody on 2023/08/20.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    
    static let identifier = "CalendarCell"
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "20"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    func configure(item: DayComponent) {
        self.dateLabel.text = item.number
    }
    
    override func layoutSubviews() {
        self.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: self.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    override func prepareForReuse() {
        self.dateLabel.text = ""
    }
}
