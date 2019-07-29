//
//  SyncManager.swift
//  BuildSourced
//
//  Created by Chance on 5/15/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import Foundation

typealias UpdateHandler = (_ success: Bool) -> Void

class SyncManager {
    static let shared = SyncManager()
    
    public func updateAllPendings(){
        let _arrAllPendings = DBManager.shared.getAllPending()
        for i in 0..<_arrAllPendings.count{
            let _pending = _arrAllPendings[i]
            if(GlobInfo.sharedInstance.isOnline){
                _pending.sendData()
            }
        }
    }
    
    public func updateLat(lat: Double, aAsset: Asset){
        aAsset.longitude = lat
        _ = aAsset.save()
        if(GlobInfo.sharedInstance.isOnline){
            APIManager.apiManager.reqPostWithAssetsId(assetId:"\(aAsset.assetId)" , fieldName: "current_lat", Value: "\(lat)", completionHandler: {(succ, data) in
                let _msg = data["message"].stringValue
                if(!succ || !_msg.contains("SUCCESS")){
                    DBManager.shared.addLatPending(lat: lat, aAsset: aAsset)
                }
            })
        }
        else{
            DBManager.shared.addLatPending(lat: lat, aAsset: aAsset)
        }
        
    }
    
    public func updateLng(lng:Double, aAsset: Asset){
        aAsset.longitude = lng
        _ = aAsset.save()
        if(GlobInfo.sharedInstance.isOnline){
            APIManager.apiManager.reqPostWithAssetsId(assetId:"\(aAsset.assetId)" , fieldName: "current_lng", Value: "\(lng)", completionHandler: {(succ, data) in
                let _msg = data["message"].stringValue
                if(!succ || !_msg.contains("SUCCESS")){
                DBManager.shared.addLngPending(lng: lng, aAsset: aAsset)
                }
                })
        }
        else{
            DBManager.shared.addLngPending(lng: lng, aAsset: aAsset)
        }
        
    }
    

    
    public func updateMaintncFlag(flag: Bool, aAsset: Asset,handler:UpdateHandler?){
        aAsset.maintenanceFlag = flag
        _ = aAsset.save()
        if(GlobInfo.sharedInstance.isOnline){
            APIManager.apiManager.reqPostWithAssetsId(assetId:"\(aAsset.assetId)" , fieldName: "maintenance", Value: "\(flag)", completionHandler: {(succ, data) in
                let _msg = data["message"].stringValue
                if(!succ || !_msg.contains("SUCCESS")){
                    handler?(false)
                    DBManager.shared.addMaintanceFlag(flag: flag, aAsset: aAsset)
                }
                else{
                    handler?(true)
                }
            })
        }
        else{
            DBManager.shared.addMaintanceFlag(flag: flag, aAsset: aAsset)
            handler?(false)
        }
        
    }
    
    public func updateMaintncNotes(notes: String, aAsset: Asset,handler:UpdateHandler?){
        aAsset.lastNotesEntry = notes
        _ = aAsset.save()
        if(GlobInfo.sharedInstance.isOnline){
            APIManager.apiManager.reqPostWithAssetsId(assetId:"\(aAsset.assetId)" , fieldName: "notes", Value: notes, completionHandler: {(succ, data) in
                let _msg = data["message"].stringValue
                if(!succ || !_msg.contains("SUCCESS")){
                    handler?(false)
                    DBManager.shared.addMaintanceNote(notes: notes, aAsset: aAsset)
                }
                else{
                    handler?(true)
                }
            })
        }
        else{
            DBManager.shared.addMaintanceNote(notes: notes, aAsset: aAsset)
            handler?(false)
        }
        
    }
    
    public func addPhoto(image: UIImage,aAsset: Asset,handler:UpdateHandler?){
        DispatchQueue.global(qos: .utility).async {

            let _imgData = UIImageJPEGRepresentation(image, 1.0)
            do{
                let _time = Int(Date().timeIntervalSince1970)
                let _strImgName = "\(_time).jpg"
                let _absPath = getAbsolutePath(aPath: _strImgName)
                try _imgData?.write(to: URL(fileURLWithPath: _absPath))
                
                if(GlobInfo.sharedInstance.isOnline){
                    APIManager.apiManager.reqUploadPhoto(assetId: "\(aAsset.assetId)", aPath: _strImgName) { (succ, data) in
                        let _msg = data["message"].stringValue
                        if(!succ || !_msg.contains("SUCCESS")){
                            DispatchQueue.main.async {
                                handler?(false)
                                let _objPending = DBManager.shared.addPhotoPath(pPath: _strImgName, aAsset: aAsset)
                                _objPending.sendData()
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                handler?(true)
                                DBManager.shared.addPhotoPathWithSuccess(pPath: _strImgName, aAsset: aAsset)
                            }
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        _ = DBManager.shared.addPhotoPath(pPath: _strImgName, aAsset: aAsset)
                        handler?(false)
                    }
                }
            }
            catch{
                DispatchQueue.main.async {
                    handler?(false)
                }
            }
        }
        
    }
    
}
