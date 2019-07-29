//
//  GlobInfo.swift
//  SongFreedom
//
//  Created by ChanceJin on 12/24/15.
//  Copyright © 2015 ChanceJin. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD


let keyAuthKey = "AuthKey"
let keyUserEmail = "UserEmail"
let keyUserPasswd = "UserPasswd"
let keyUseMethod = "UseMethod"
let keyLastSynced = "LastSynced"
let keySignIn = "SignIn"

extension Notification.Name{
    static let Notify_WIFION = Notification.Name("Notify_WIFION")
    static let Notify_WIFIOFF = Notification.Name("Notify_WIFIOFF")
    static let Notify_APPMODECHANGED = Notification.Name("Notify_APPMODECHANGED")
    static let Notify_PENDINGCHANGED = Notification.Name("Notify_PENDINGCHANGED")
}

class GlobInfo {
    
    private let standardUserDefaults = UserDefaults.standard
    static let sharedInstance = GlobInfo()
    //private var mainNav : UINavigationController!
    let _reachbility = Reachability()!
    
    // MARK: - User Property
    
    var isSync: Bool = false
    
    var isOnline: Bool{
        get{
            return _reachbility.currentReachabilityStatus == .notReachable ? false:true
        }
    }
    
    var authKey : String{
        get{
            return standardUserDefaults.string(forKey: keyAuthKey) ?? ""
        }
        set{
            standardUserDefaults .set(newValue, forKey: keyAuthKey)
        }
    }
    
    var userEmail : String{
        get{
            return standardUserDefaults.string(forKey: keyUserEmail) ?? ""
        }
        set{
            standardUserDefaults .set(newValue, forKey: keyUserEmail)
        }
    }
    
    var userPasswd : String{
        get{
            return standardUserDefaults.string(forKey: keyUserPasswd) ?? ""
        }
        set{
            standardUserDefaults.set(newValue, forKey: keyUserPasswd)
        }
    }
    
    var isSignedIn: Bool{
        get{
            return standardUserDefaults.bool(forKey: keySignIn)
        }
        set{
            standardUserDefaults.set(newValue, forKey: keySignIn)
        }
    }
    
    var isUseApp: Bool{
        get{
            return standardUserDefaults.bool(forKey: keyUseMethod)
        }
        set{
            standardUserDefaults.set(newValue, forKey: keyUseMethod)
        }
    }
    
    var lastSynced : Date{
        get{
            let _value = standardUserDefaults.double(forKey: keyLastSynced)
            if(_value == 0){
                return dateFromString(strDate: "2000-01-01 00:00:00")
            }
            return Date(timeIntervalSince1970: _value)
            
        }
        set{
            standardUserDefaults.set(newValue.timeIntervalSince1970, forKey: keyLastSynced)
        }
    }
    
    func globalInit(){
        
        initReachability()
        ToastManager.shared.queueEnabled = true
    }
    
    func initReachability(){
        
        _reachbility.whenReachable = {reachbility in
            DispatchQueue.main.async{
                if reachbility.isReachableViaWiFi {
                    //wifi
                    
                }
                else{
                    //celluar
                }
                
                if(GlobInfo.sharedInstance.isSignedIn){
                    SyncManager.shared.updateAllPendings()
                    APIManager.apiManager.reqUpdatedSince(fromDate: dateString(date: GlobInfo.sharedInstance.lastSynced)){[unowned self](succ, data) in
                        if(succ){
                            DispatchQueue.main.async{
                                self.isSync = true
                                SVProgressHUD.show(withStatus: "Syncing")
                                DBManager.shared.syncData(data: data)
                                self.isSync = false
                                SVProgressHUD.dismiss()
                            }
                            
                        }
                    }
                }
                
                NotificationCenter.default.post(name:.Notify_WIFION, object: nil)
            }
            
            //notify
        }
        
        _reachbility.whenUnreachable = {reachbility in
            DispatchQueue.main.async{
                //not reachable
                //notify
                NotificationCenter.default.post(name:.Notify_WIFIOFF, object: nil)
            }
        }
        do{
            try _reachbility.startNotifier()
        }
        catch{
            
        }
        
        
    }
    
    // MARK: - Goto Right views
    func gotoLogin(){
        //self.mainNav.isNavigationBarHidden = false
        //self.mainNav.setViewControllers([StoryboardScene.Main.settingVC()], animated: true)
        let _vcNav = UINavigationController(rootViewController: StoryboardScene.Main.settingVC())
        _vcNav.automaticallyAdjustsScrollViewInsets = false
        _vcNav.navigationBar.isTranslucent = false
        _vcNav.setAsRoot()
    }
        
    func gotoMainView(){
        
        let _vcMain = UINavigationController(rootViewController: StoryboardScene.Main.mainVC())
        let _vcHelp = UINavigationController(rootViewController: StoryboardScene.Main.helpVC())
        
        setNavProperty(viewNav: _vcMain)
        setNavProperty(viewNav: _vcHelp)
        
        let _vcTab = UITabBarController()
        _vcTab.tabBar.isTranslucent = false
        _vcTab.automaticallyAdjustsScrollViewInsets = false
        
        if(self.isUseApp){
            _vcTab.setViewControllers([_vcMain,_vcHelp], animated: false)
            _vcTab.selectedIndex = 0
        }
        else{
            let _vcWebHome = UINavigationController(rootViewController: StoryboardScene.Main.webHomeVC())
            setNavProperty(viewNav: _vcWebHome)
            _vcTab.setViewControllers([_vcMain,_vcWebHome,_vcHelp], animated: false)
            _vcTab.selectedIndex = 1
        }
        setTabBar(_vcTab.tabBar)
        _vcTab.setAsRoot()
        
        //self.mainNav.setViewControllers([_vcMain], animated: true)
        //self.mainNav.isNavigationBarHidden = false
        //self.mainNav.setViewControllers([StoryboardScene.Main.mainVC()], animated: true)
    }
    
    func setTabBar(_ _tabbar: UITabBar){
        //let _tabbar = _vcTab.tabBar
        for i in 0...3{
            let _viewSep = _tabbar.viewWithTag(100 + i)
            if let _viewExistSep = _viewSep{
                _viewExistSep.removeFromSuperview()
            }
        }
        
        let _itemWidth = floor(_tabbar.frame.size.width / CGFloat(_tabbar.items!.count))
        let _itemHeight = _tabbar.frame.size.height
        
        _tabbar.selectionIndicatorImage = UIImage().makeImageWithColorAndSize(color: UIColor(named:.AppBlue), size: CGSize(width:_itemWidth,height:_itemHeight))
        _tabbar.barTintColor = .white
        _tabbar.backgroundColor = .white
        _tabbar.tintColor = .white
        _tabbar.unselectedItemTintColor = UIColor(named: .AppBlue)
        
        let _itemScan = _tabbar.items![0]
        _itemScan.title = "SCAN"
        _itemScan.image = UIImage(named: "icon_scan_d")
        
        
        var _nHelpIndex = 1
        if(!self.isUseApp){
            _nHelpIndex = 2
            let _itemHome = _tabbar.items![1]
            _itemHome.title = "HOME"
            _itemHome.image = UIImage(named: "icon_home_d")
            
        }
        let _itemHelp = _tabbar.items![_nHelpIndex]
        _itemHelp.title = "HELP"
        _itemHelp.image = UIImage(named: "icon_help_d")
        
        
        let _sepWidth :CGFloat = 0.5
        for i in 0..<(_tabbar.items!.count - 1){
            let _viewSep = UIView(frame: CGRect(x: _itemWidth * CGFloat(i+1)-CGFloat(_sepWidth/2), y: 0, width: _sepWidth, height:_itemHeight))
            _viewSep.tag = 100 + i
            _viewSep.backgroundColor = .lightGray
            _tabbar.addSubview(_viewSep)
        }
    }
    
    func changeAppMode(aUseApp: Bool){
        SVProgressHUD.dismiss()
        if(GlobInfo.sharedInstance.isSignedIn){
            let _vcTab = UIApplication.shared.keyWindow!.rootViewController! as! UITabBarController
            if(!self.isUseApp && aUseApp){
                self.isUseApp = aUseApp
                _vcTab.setViewControllers([_vcTab.viewControllers![0],_vcTab.viewControllers![2]], animated: true)
                _vcTab.selectedIndex = 0
                //print("appmode setting tab to 0")
                setTabBar(_vcTab.tabBar)
            }
            else if(self.isUseApp && !aUseApp){
                self.isUseApp = aUseApp
                let _vcWebHome = UINavigationController(rootViewController: StoryboardScene.Main.webHomeVC())
                setNavProperty(viewNav: _vcWebHome)
                _vcTab.setViewControllers([_vcTab.viewControllers![0],_vcWebHome,_vcTab.viewControllers![1]], animated: true)
                _vcTab.selectedIndex = 1
                //print("webmode setting tab to 1")
                setTabBar(_vcTab.tabBar)
            }
            NotificationCenter.default.post(name:.Notify_APPMODECHANGED, object: nil)
        }
        else{
            self.isUseApp = aUseApp
        }
    }
    
    
    func setNavProperty(viewNav: UINavigationController!){
        viewNav.automaticallyAdjustsScrollViewInsets = false
        viewNav.navigationBar.isTranslucent = false
    }
    
    func gotoWebHandler(_ aUrl: String){
        if(!self.isUseApp){
            let _vcTab = UIApplication.shared.keyWindow!.rootViewController! as! UITabBarController
            _vcTab.selectedIndex = 1
            let _navRoot = _vcTab.viewControllers![1] as! UINavigationController
            let _vcWebHome = _navRoot.viewControllers[0] as! WebHomeVC
            _vcWebHome.handleUrl(aUrl)
        }
    }
    
    func startApp(){
        //self.mainNav = UIApplication.shared.keyWindow!.rootViewController! as! UINavigationController

        self.globalInit()
        guard self.isSignedIn else{
            gotoLogin()
            return
        }
        
        gotoMainView()
    }
    
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.height
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.width
    }
}

extension UIImage{
    
    func makeImageWithColorAndSize(color: UIColor, size: CGSize)->UIImage{
        UIGraphicsBeginImageContext(size)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}
