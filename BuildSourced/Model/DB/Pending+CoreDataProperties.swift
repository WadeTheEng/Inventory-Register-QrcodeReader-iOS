//
//  Pending+CoreDataProperties.swift
//  BuildSourced
//
//  Created by Chance on 5/15/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import Foundation
import CoreData

extension Pending {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pending> {
        return NSFetchRequest<Pending>(entityName: "Pending");
    }
    
    public func getPendingname()->String{
        switch(pendKind){
        case 0:
            return "Lat Update"
        case 1:
            return "Lng Update"
        case 3:
            return "Maintenance Update"
        case 4:
            return "Maintenance Update"
        default:
            return "Image Added"
        }
    }
    
    public func sendData(){
        switch(pendKind){
        case 0:
            APIManager.apiManager.reqPostWithAssetsId(assetId:"\(parentAsset!.assetId)" , fieldName: "current_lat", Value: self.latitude!, completionHandler: {[weak self](succ, data) in
                
                    self?.handleSendResponse(succ: succ, data: data)
                })

        case 1:
            APIManager.apiManager.reqPostWithAssetsId(assetId:"\(parentAsset!.assetId)" , fieldName: "current_lng", Value: self.longitude!, completionHandler: {[weak self](succ, data) in
                    self?.handleSendResponse(succ: succ, data: data)
            })
        case 3:
            APIManager.apiManager.reqPostWithAssetsId(assetId:"\(parentAsset!.assetId)" , fieldName: "maintenance", Value: "\(self.maintenanceFlag)", completionHandler: {[weak self](succ, data) in
                self?.handleSendResponse(succ: succ, data: data)
            })
        case 4:
            APIManager.apiManager.reqPostWithAssetsId(assetId:"\(parentAsset!.assetId)" , fieldName: "notes", Value: maintenanceNotes!, completionHandler: {[weak self](succ, data) in
                self?.handleSendResponse(succ: succ, data: data)
            })
        default:
            APIManager.apiManager.reqUploadPhoto(assetId: "\(parentAsset!.assetId)", aPath: photoPath!) {[weak self](succ, data) in
                
                self?.handleSendResponse(succ: succ, data: data)
            }

        }
    }
    
    func handleSendResponse(succ: Bool, data: JSON){
        let _msg = data["message"].stringValue
        if(!succ || !_msg.contains("SUCCESS")){
           //fail
            if(GlobInfo.sharedInstance.isOnline){
                self.sendData()
            }
        }
        else{
           //success
           DBManager.shared.deletePending(aPending: self)
           
        }
    }


    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var maintenanceFlag: Bool
    @NSManaged public var pendDate: NSDate?
    @NSManaged public var pendKind: Int16 //0:lat 1: lng 3:Flag 4: notes 5: photo
    @NSManaged public var photoPath: String?
    @NSManaged public var maintenanceNotes: String?
    @NSManaged public var parentAsset: Asset?

}
