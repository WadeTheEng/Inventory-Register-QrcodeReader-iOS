//
//  TrackingCode+CoreDataProperties.swift
//  BuildSourced
//
//  Created by Chance on 5/12/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import Foundation
import CoreData

extension TrackingCode {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackingCode> {
        return NSFetchRequest<TrackingCode>(entityName: "TrackingCode");
    }

    @NSManaged public var guidValue: String?
    @NSManaged public var parentAsset: Asset?

}
