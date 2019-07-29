//
//  DBManager.swift
//  BuildSourced
//
//  Created by Chance on 5/12/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit

class DBManager {
    static let shared = DBManager()
    public func initDB(){
        Asset.deleteAll()

    }
    
    public func syncData(data:JSON){
        if let _deletedSince = data["deleted_since"].array{
            for i in 0..<_deletedSince.count{
                let _delID = _deletedSince[i].numberValue
                deleteAsset(aDelId: _delID)
            }
        }
        
        let _assetsTemp = data["assets"].array
        if let _assetsArr = _assetsTemp {
            for i in 0..<_assetsArr.count{
                let _asset = _assetsArr[i].dictionaryObject
                createAsset(aAsset: _asset!)
            }
        }
        
        let _strLastUpdate = data["last_updated_at"].stringValue
        let _formater = DateFormatter()
        _formater.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        if let _dateLast = _formater.date(from: _strLastUpdate){
            GlobInfo.sharedInstance.lastSynced = _dateLast
        }
        
    }
    
    public func getAssetWithId(aAssetId: Int32) -> Asset?{
        var _asset = Asset.query(["assetId":aAssetId]) as! [Asset]
        if(_asset.count > 0){
            let _aCode = _asset[0]
            return _aCode
        }
        return nil
    }
    
    public func getAsset(aTokenId: String) -> Asset?{
        var _tracking = TrackingCode.query(["guidValue":aTokenId]) as! [TrackingCode]
        if(_tracking.count > 0){
            let _aCode = _tracking[0]
            return _aCode.parentAsset!
        }
        return nil
    }
    
    public func deleteAsset(aDelId: NSNumber){
        var _assets = Asset.query(["assetId":aDelId]) as! [Asset]
        if(_assets.count > 0){
            _assets[0].delete()
        }
    }
    
    public func updateAsset(aAsset: [String:Any]){
        let _id = aAsset["id"] as! NSNumber
        deleteAsset(aDelId:_id)
        createAsset(aAsset: aAsset)
        
    }
    
    public func createAsset(aAsset: [String:Any]){
        
        let _objAsset = Asset.create(properties: aAsset) as! Asset
        if(_objAsset.assetName == nil){
            _objAsset.assetName = ""
        }
        
        if(_objAsset.assetAddress == nil){
            _objAsset.assetAddress = ""
        }
        
        if(_objAsset.assetDescription == nil){
            _objAsset.assetDescription = ""
        }
        
        if(_objAsset.assetNumber == nil){
            _objAsset.assetNumber = ""
        }
        
        if(_objAsset.lastNotesEntry == nil){
            _objAsset.lastNotesEntry = ""
        }
        
        let _trackingCodes = aAsset["tracking_codes"]
            let _arrCodes = _trackingCodes as! [String]
            for j in 0..<_arrCodes.count{
                let _objTrack = TrackingCode.create(properties: ["guidValue":_arrCodes[j]]) as! TrackingCode
                _objTrack.parentAsset = _objAsset
                _ = _objTrack.save()
            }
        _ = _objAsset.save()
    }
    
    public func deletePending(aPending: Pending){
        aPending.delete()
        _ = Pending.save()
        NotificationCenter.default.post(name:.Notify_PENDINGCHANGED, object: nil)
        ///notify
    }

    public func addLngPending(lng:Double, aAsset: Asset){
        

        var _pendings = Pending.query(["pendKind":NSNumber(value: 1),"parentAsset":aAsset]) as! [Pending]
        if(_pendings.count > 0){
            _pendings[0].delete()
        }
        
        let _objPending = Pending.create(properties: ["pendKind":NSNumber(value: 1),"longitude":"\(lng)","pendDate":Date()]) as! Pending
        _objPending.parentAsset = aAsset
        _ = _objPending.save()
        _ = aAsset.save()
        
        NotificationCenter.default.post(name:.Notify_PENDINGCHANGED, object: nil)
    }
    
    public func addLatPending(lat: Double,aAsset: Asset){

        var _pendings = Pending.query(["pendKind":NSNumber(value: 0),"parentAsset":aAsset]) as! [Pending]
        if(_pendings.count > 0){
            _pendings[0].delete()
        }
        
        let _objPending = Pending.create(properties: ["pendKind":NSNumber(value: 0),"latitude":"\(lat)","pendDate":Date()]) as! Pending
        _objPending.parentAsset = aAsset
        _ = _objPending.save()
        _ = aAsset.save()
        
        NotificationCenter.default.post(name:.Notify_PENDINGCHANGED, object: nil)
    }
    
    public func addMaintanceFlag(flag: Bool,aAsset: Asset){

        var _pendings = Pending.query(["pendKind":NSNumber(value: 3),"parentAsset":aAsset]) as! [Pending]
        if(_pendings.count > 0){
            _pendings[0].delete()
        }
        
        let _objPending = Pending.create(properties: ["pendKind":NSNumber(value: 3),"maintenanceFlag":NSNumber(value:flag),"pendDate":Date()]) as! Pending
        _objPending.parentAsset = aAsset
        _ = _objPending.save()
        _ = aAsset.save()
        
        NotificationCenter.default.post(name:.Notify_PENDINGCHANGED, object: nil)
    }
    
    public func addMaintanceNote(notes: String,aAsset: Asset){
        
        var _pendings = Pending.query(["pendKind":NSNumber(value: 4),"parentAsset":aAsset]) as! [Pending]
        if(_pendings.count > 0){
            _pendings[0].delete()
        }
        
        let _objPending = Pending.create(properties: ["pendKind":NSNumber(value: 4),"maintenanceNotes":notes,"pendDate":Date()]) as! Pending
        _objPending.parentAsset = aAsset
        _ = _objPending.save()
        _ = aAsset.save()
        
        NotificationCenter.default.post(name:.Notify_PENDINGCHANGED, object: nil)
    }
    
    public func addPhotoPath(pPath: String,aAsset: Asset) -> Pending{
        let _objPending = Pending.create(properties: ["pendKind":NSNumber(value: 5),"photoPath":pPath,"pendDate":Date()]) as! Pending
        _objPending.parentAsset = aAsset
        _ = _objPending.save()
        if(aAsset.imageUrls == nil){
            aAsset.imageUrls = [String]()
        }
        aAsset.imageUrls?.append(pPath)
        _ = aAsset.save()
        NotificationCenter.default.post(name:.Notify_PENDINGCHANGED, object: nil)
        return _objPending
    }
    
    public func addPhotoPathWithSuccess(pPath: String,aAsset: Asset){
        if(aAsset.imageUrls == nil){
            aAsset.imageUrls = [String]()
        }
        aAsset.imageUrls?.append(pPath)
        _ = aAsset.save()
    }
    
    public func getAllPendingCount() -> Int{
        return Pending.count()
    }
    
    public func getAllPending()->[Pending]{
        return Pending.all(sort:"pendDate DESC") as! [Pending]
    }

    public func getAllAssetsHavePending()->[Asset]{
        
        let _arrPending = getAllPending()
        var _arrAsset = [Asset]()
        for i in 0..<_arrPending.count{
            let _pending = _arrPending[i]
            if(!_arrAsset.contains(_pending.parentAsset!)){
                _arrAsset.append(_pending.parentAsset!)
            }
            
        }
        return _arrAsset
    }
    
   
}
