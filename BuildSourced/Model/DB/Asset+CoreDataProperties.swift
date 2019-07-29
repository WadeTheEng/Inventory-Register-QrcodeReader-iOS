//
//  Asset+CoreDataProperties.swift
//  BuildSourced
//
//  Created by Chance on 5/12/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import Foundation
import CoreData

extension Asset {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Asset> {
        return NSFetchRequest<Asset>(entityName: "Asset");
    }
    
    override public class func mappings() -> [String:String] {
        return ["assetId":"id","assetName":"name","assetDescription":"description","mileage":"mileage","latitude":"latitude","longitude":"longitude","lastNotesEntry":"last_notes_entry","assetNumber":"asset_number","rental":"rental","publicFlag":"public","maintenanceFlag":"maintenance_flag","clientContactInformation":"client_contact_information","imageUrls":"image_urls","projectId":"project_id"]
    }
    
    
    public func getPendingCount()->Int{
        if let _arrObjects = self.pendings?.allObjects{
            return _arrObjects.count
        }
        else {
            return 0
        }
    }
    
    public func getPendingArray()->[Pending]{
        if let _arrObjects = self.pendings?.allObjects{
            return _arrObjects.sorted(by: { (first, second) -> Bool in
                let _firstPend = first as! Pending
                let _secondPend = second as! Pending
                if(_firstPend.pendDate!.timeIntervalSince1970 > _secondPend.pendDate!.timeIntervalSince1970){
                    return true
                }
                return false
            }) as! [Pending]
        }
        else {
            return [Pending]()
        }
    }

    @NSManaged public var assetAddress: String?
    @NSManaged public var assetDescription: String?
    @NSManaged public var assetId: Int32
    @NSManaged public var assetName: String?
    @NSManaged public var assetNumber: String?
    @NSManaged public var clientContactInformation: String?
    @NSManaged public var imageUrls: [String]?
    @NSManaged public var lastNotesEntry: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var maintenanceFlag: Bool
    @NSManaged public var mileage: Int32
    @NSManaged public var projectId: Int32
    @NSManaged public var publicFlag: Bool
    @NSManaged public var rental: Bool
    @NSManaged public var pendings: NSSet?
    @NSManaged public var trackingCodes: NSSet?

}

// MARK: Generated accessors for trackingCodes
extension Asset {

    @objc(addTrackingCodesObject:)
    @NSManaged public func addToTrackingCodes(_ value: TrackingCode)

    @objc(removeTrackingCodesObject:)
    @NSManaged public func removeFromTrackingCodes(_ value: TrackingCode)

    @objc(addTrackingCodes:)
    @NSManaged public func addToTrackingCodes(_ values: NSSet)

    @objc(removeTrackingCodes:)
    @NSManaged public func removeFromTrackingCodes(_ values: NSSet)

}

// MARK: Generated accessors for pendings
extension Asset {

    @objc(addPendingsObject:)
    @NSManaged public func addToPendings(_ value: Pending)

    @objc(removePendingsObject:)
    @NSManaged public func removeFromPendings(_ value: Pending)

    @objc(addPendings:)
    @NSManaged public func addToPendings(_ values: NSSet)

    @objc(removePendings:)
    @NSManaged public func removeFromPendings(_ values: NSSet)

}
