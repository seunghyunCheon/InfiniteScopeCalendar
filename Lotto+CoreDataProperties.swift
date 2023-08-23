//
//  Lotto+CoreDataProperties.swift
//  InfiniteCalendarScope
//
//  Created by Brody on 2023/08/23.
//
//

import Foundation
import CoreData


extension Lotto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lotto> {
        return NSFetchRequest<Lotto>(entityName: "Lotto")
    }

    @NSManaged public var type: String?
    @NSManaged public var date: Date?
    @NSManaged public var amount: Int64

}

extension Lotto : Identifiable {

}
