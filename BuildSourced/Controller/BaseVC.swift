//
//  BaseVC.swift
//  BuildSourced
//
//  Created by Chance on 4/18/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {
    var viewBadge: BadgeSwift?
    var lbTitle: UILabel!
    var bShowSetting: Bool = false
    var bShowPending: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(changeSettingState), name: .Notify_WIFION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeSettingState), name: .Notify_WIFIOFF, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeSettingState), name: .Notify_APPMODECHANGED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changePendingState), name: .Notify_PENDINGCHANGED, object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    func setCustomTitle(_ aTitle: String){
        lbTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        self.navigationItem.titleView = lbTitle
        lbTitle.textAlignment = .center
        lbTitle.text = aTitle
    }
    
    func showPendingButton(){
        
        bShowPending = true
        viewBadge = BadgeSwift()
        viewBadge?.text = "\(DBManager.shared.getAllPendingCount())"
        
        // Insetsd
        viewBadge?.insets = CGSize(width: 2, height: 2)
        
        // Font
        viewBadge?.font = UIFont.systemFont(ofSize: 12)
        
        // Text color
        viewBadge?.textColor = UIColor.white
        
        // Badge color
        viewBadge?.badgeColor = UIColor(named: .AppGreen)
        // Shadow
        viewBadge?.shadowOpacityBadge = 0.5
        viewBadge?.shadowOffsetBadge = CGSize(width: 0, height: 0)
        viewBadge?.shadowRadiusBadge = 1.0
        viewBadge?.shadowColorBadge = UIColor.clear
        
        // No shadow
        viewBadge?.shadowOpacityBadge = 0
        
        // Border width and color
        viewBadge?.borderWidth = 1.0
        viewBadge?.borderColor = UIColor(named: .AppGreen)
        
        // Customize the badge corner radius.
        // -1 if unspecified. When unspecified, the corner is fully rounded. Default: -1.
        //viewBadge?.cornerRadius = 10
        
        let _parentBadge = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let _btnBadge = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        _btnBadge.backgroundColor = UIColor.clear
        _btnBadge.addTarget(self, action: #selector(onTapBadge), for:UIControlEvents.touchUpInside)
        viewBadge?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        _parentBadge.addSubview(viewBadge!)
        _parentBadge.addSubview(_btnBadge)
        
        
        self.navigationItem.leftBarButtonItem
         = UIBarButtonItem(customView: _parentBadge)
    }
    
    func onTapBadge(){
        self.navigationController?.pushViewController(StoryboardScene.Main.pendingList(), animated: true)
    }
    
    func changePendingState(){
        if(bShowPending){
            viewBadge?.text = "\(DBManager.shared.getAllPendingCount())"
            //showPendingButton()
        }
    }
    
    func changeSettingState(){
        if(bShowSetting){
            showSettingItems()
        }
    }
    
    func showSettingItems(){
        bShowSetting = true
        let _viewContent = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        var _btnSetting: UIButton!
        var _btnApp: UIButton!
        var _btnBrowser: UIButton!
        _btnSetting = UIButton(frame: CGRect(x: 40, y: 0, width: 30, height: 30))
        _btnSetting.setImage(UIImage(named: "icon_setting"), for: UIControlState.normal)
        _btnSetting.addTarget(self, action: #selector(onTapSetting), for:UIControlEvents.touchUpInside)
        _viewContent.addSubview(_btnSetting)
        var _strHighSuffix = "d"
        if(GlobInfo.sharedInstance.isOnline){
            _strHighSuffix = "h"
        }
        
        if(GlobInfo.sharedInstance.isUseApp){
            _btnApp = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            
            _btnApp.setImage(UIImage(named: "icon_app_" + _strHighSuffix), for: UIControlState.normal)
            _btnApp.addTarget(self, action: #selector(onTapApp), for:UIControlEvents.touchUpInside)
            _viewContent.addSubview(_btnApp)
        }
        else{
            _btnBrowser = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            _btnBrowser.setImage(UIImage(named: "icon_browser_" + _strHighSuffix), for: UIControlState.normal)
            _btnBrowser.addTarget(self, action: #selector(onTapApp), for:UIControlEvents.touchUpInside)
            _viewContent.addSubview(_btnBrowser)
        }

        self.navigationItem.rightBarButtonItem
            = UIBarButtonItem(customView: _viewContent)
    }
    
    func onTapSetting(){
        let _setting = UINavigationController(rootViewController: StoryboardScene.Main.settingVC())
        _setting.automaticallyAdjustsScrollViewInsets = false
        _setting.navigationBar.isTranslucent = false
        self.present(_setting, animated: true, completion: nil)
         
    }
    
    func onTapApp(){
        
    }

    func onTapBrowser(){
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
