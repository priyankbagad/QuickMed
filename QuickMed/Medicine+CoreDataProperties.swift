//
//  Medicine+CoreDataProperties.swift
//  QuickMed
//
//  Created by Priyank Bagad on 7/21/25.
//
//

import Foundation
import CoreData


extension Medicine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Medicine> {
        return NSFetchRequest<Medicine>(entityName: "Medicine")
    }

    @NSManaged public var name: String?
    @NSManaged public var dosage: String?
    @NSManaged public var frequency: Int16
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var time: Date?
    @NSManaged public var selectedDays: String?
    @NSManaged public var notificationIDs: String?

}

extension Medicine : Identifiable {

}
