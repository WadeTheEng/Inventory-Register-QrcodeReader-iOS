//
//  APIManager.swift
//  SongFreedom
//
//  Created by ChanceJin on 12/24/15.
//  Copyright © 2015 ChanceJin. All rights reserved.
//

import Foundation
import Alamofire


typealias NetHandler = (_ success: Bool, _ data: JSON) -> Void

class APIManager {
    
    static let apiManager = APIManager()
    
    // MARK: -
    private func postPath(methodName: APIName, param: [String:String]?, header: HTTPHeaders?, completionHandler:@escaping NetHandler){
        let (apiPath,method) = methodName.Name()
        var _strFullURL : String = URL_APIServer + apiPath
        /*if(true)//debug
        {
            _strFullURL += ".php"
        }
        else
        {
        }*/
        if let _getParam = param?["getParam"]{
            _strFullURL = _strFullURL + "/" + _getParam
        }

        
        var _headers :HTTPHeaders = ["X-User-Api-Key":GlobInfo.sharedInstance.authKey]
        
        if(header != nil){
            _headers = header!
        }
        
        //SVProgressHUD.show()
        Alamofire.request(_strFullURL, method: method, parameters: param, encoding: URLEncoding.default,headers:_headers).responseJSON { response in
            //SVProgressHUD.dismiss()
            if let json = response.result.value {
                
                //print(json)
                let _resultJson = JSON(json)
                completionHandler(true, _resultJson)
                /*
                if _resultJson["success"].intValue == 1 {
                    completionHandler(true,_resultJson)
                }
                else{
                    completionHandler(false,_resultJson)
                }*/
            }
            else{
                completionHandler(false,JSON(["error":"Can't connect to the server.Please check the network connection!"]))
            }
        }
        
    }
    
    // MARK: - Requests
    
    func reqLogin(email: String, passwd: String, completionHandler: @escaping NetHandler){
        
        var deviceID = UIDevice.current.identifierForVendor!.uuidString
        deviceID = deviceID.replacingOccurrences(of: "-", with: "")
        //deviceID = "2b6f0cc904d137be2e1730235f5664094b831186"//debug
        let _strEmailPass = email + ":" + passwd
        //let _strEmailPass = "ca1@a.com:password1"//debug
        let _autho = "Basic " + _strEmailPass.toBase64()
        let headers: HTTPHeaders = [
            "authorization": _autho
        ]
        
        postPath(methodName: .Login, param: ["udid":deviceID], header: headers){ (success,data) in
            if(success){
                let _token = data["token"].stringValue
                let _combined = deviceID + "+" + _token
                let _shaValue = _combined.get_sha256_String()
                let _authKey = _shaValue + ":" + deviceID
                GlobInfo.sharedInstance.authKey = _authKey.toBase64()
                completionHandler(true,data)
            }
            else{
                completionHandler(false,data)
            }
        }
        
    }
    
    func reqUpdatedSince(fromDate: String, completionHandler: @escaping NetHandler){
        postPath(methodName:.UpdatedSince, param: ["from":fromDate], header:nil, completionHandler: completionHandler)
    }
    
    func reqInitialUpdate(completionHandler: @escaping NetHandler){
        postPath(methodName:.UpdatedSince, param: ["from":dateString(date: dateFromString(strDate: "2000-01-01 00:00:00"))], header:nil, completionHandler: completionHandler)
    }

    func reqGetAssetWithTokenId(tokenId: String, completionHandler: @escaping NetHandler){
        postPath(methodName:.GetWithTokenId, param: ["getParam":tokenId], header:nil, completionHandler: completionHandler)
    }
    
    func reqPostWithAssetsId(assetId: String,fieldName: String, Value: String, completionHandler: @escaping NetHandler){
        let _osLevel = UIDevice.current.systemVersion
        let _phone_type = UIDevice.current.type
        let _timestamp = dateString(date: Date())
        postPath(methodName:.PostWithAssetsId, param: ["getParam":assetId,"field_name":fieldName,"value":Value,"os_level":_osLevel,"phone_type":_phone_type.rawValue,"timestamp":_timestamp], header:nil, completionHandler: completionHandler)
    }
    
    func reqUploadPhoto(assetId: String,aPath: String,completionHandler: @escaping NetHandler){
        DispatchQueue.global(qos: .utility).async{
            do{
                let _absPath = getAbsolutePath(aPath: aPath)
                let _imgData = try Data(contentsOf: URL(fileURLWithPath: _absPath))
                let _headers :HTTPHeaders = ["X-User-Api-Key":GlobInfo.sharedInstance.authKey]
                let _urlForUPload = URL_APIServer + "assets/\(assetId)/addPhoto"
                Alamofire.upload(multipartFormData: { multipartFormData in
                    
                    multipartFormData.append(_imgData, withName: "file", fileName: "file.png", mimeType: "image/png")
                    }, to: _urlForUPload, method: .post, headers:_headers,
                        encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON{ response in
                                    
                                    if let json = response.result.value {
                                        let _resultJson = JSON(json)
                                        completionHandler(true, _resultJson)

                                    }
                                    else{
                                        
                                        completionHandler(false,JSON(["error":"Can't connect to the server.Please check the network connection!"]))
                                    }

                                    //debugPrint(response)
                                }
                            case .failure(let encodingError):
                                print("error:\(encodingError)")
                            }
                })
            }
            catch{
                print(error)
                completionHandler(false,JSON(["error":"Can't read the photo file"]))
            }
            
        }
        
    }
    
    
}
