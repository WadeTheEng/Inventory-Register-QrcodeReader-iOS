//
//  ViewController.swift
//  BuildSourced
//
//  Created by Chance on 4/12/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit
import SVProgressHUD


class SettingVC: BaseVC {
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPasswd: UITextField!
    @IBOutlet weak var lbError: UILabel!
    @IBOutlet weak var btnUpdate: UIButton!
    
    @IBOutlet weak var btnCollapse: UIButton!
    @IBOutlet weak var viewCredential: UIView!
    var bCollapse: Bool = false
    @IBOutlet weak var lbCredentialInfo: UILabel!
    
    @IBOutlet weak var viewUseApp: UIView!
    @IBOutlet weak var viewUseBrowser: UIView!
    @IBOutlet weak var ivUseApp: UIImageView!
    @IBOutlet weak var ivUseBrowser: UIImageView!
    @IBOutlet weak var lbUseAppTitle: UILabel!
    @IBOutlet weak var lbUseAppDesc: UILabel!
    @IBOutlet weak var lbUseBrowserTitle: UILabel!
    @IBOutlet weak var lbUseBrowserDesc: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(GlobInfo.sharedInstance.isSignedIn){
            setCustomTitle("Settings")
            showCloseButton()
            showPendingButton()
            txtEmail.text = GlobInfo.sharedInstance.userEmail
            txtPasswd.text = GlobInfo.sharedInstance.userPasswd
            bCollapse = true
            collapseCredential()
            
        }
        else{
            setCustomTitle("Login")
            btnUpdate.setTitle("Login", for: .normal)
            btnCollapse.isHidden = true
            lbCredentialInfo.text = "Credential Information"
        }
        changeUseMethod(GlobInfo.sharedInstance.isUseApp)
        
        //self.view.makeFailedToast("Settings Update Successful")
        //self.view.makeSuccessToast("Settings Update Successful")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showCloseButton(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action:#selector(onClose))
    }

    func onClose(){
        SVProgressHUD.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapUpdate(_ sender: AnyObject) {
        lbError.isHidden = true
        if(txtEmail.text!.isEmpty || txtPasswd.text!.isEmpty){
            lbError.isHidden = false
            lbError.text = "Please input your email and password."
            return
        }
        SVProgressHUD.show(withStatus: "Syncing")
        //self.view.makeToastActivity(.center)
        self.view.isUserInteractionEnabled = false
        APIManager.apiManager.reqLogin(email: txtEmail.text!, passwd: txtPasswd.text!) { [weak self](success, data) in
            SVProgressHUD.dismiss()
            if let _safeSelf = self {
                if(success){
                    
                    GlobInfo.sharedInstance.userEmail = _safeSelf.txtEmail.text!
                    GlobInfo.sharedInstance.userPasswd = _safeSelf.txtPasswd.text!
                    
                    _safeSelf.view.makeSuccessToast("Login Success! Syncing data...")
                    SVProgressHUD.show(withStatus: "Syncing")
                    APIManager.apiManager.reqInitialUpdate(completionHandler: { (succ, data) in
                        SVProgressHUD.dismiss()
                        
                        GlobInfo.sharedInstance.isSignedIn = true
                        GlobInfo.sharedInstance.gotoMainView()
                        if(succ){
                            DBManager.shared.initDB()
                            DBManager.shared.syncData(data: data)
                        }
                    })
                    
                }
                else{
                    _safeSelf.view.isUserInteractionEnabled = true
                    let _strMessage = data["error"].string ?? ""
                    _safeSelf.lbError.isHidden = false
                    _safeSelf.lbError.text = _strMessage
                }
            }
        }
        
    }
    
    @IBAction func onTapUseApp(_ sender: AnyObject) {
        changeUseMethod(true)
        GlobInfo.sharedInstance.changeAppMode(aUseApp:true)
    }

    @IBAction func onTapUseBrowser(_ sender: AnyObject) {
       changeUseMethod(false)
        GlobInfo.sharedInstance.changeAppMode(aUseApp:false)
    }
    
    @IBAction func onTapCollapse(_ sender: AnyObject) {
        bCollapse = !bCollapse
        collapseCredential()
    }
    
    func changeUseMethod(_ bApp: Bool){
        
        if(bApp){
            viewUseApp.backgroundColor = UIColor(named: .AppBlue)
            viewUseBrowser.backgroundColor = UIColor.white
            ivUseApp.image = UIImage(named: "icon_app_white")
            ivUseBrowser.image = UIImage(named: "icon_browser_blue")
        }
        else{
            viewUseBrowser.backgroundColor = UIColor(named: .AppBlue)
            viewUseApp.backgroundColor = UIColor.white
            ivUseApp.image = UIImage(named: "icon_app_blue")
            ivUseBrowser.image = UIImage(named: "icon_browser_white")
        }
        
        lbUseAppTitle.textColor = viewUseBrowser.backgroundColor
        lbUseAppDesc.textColor = viewUseBrowser.backgroundColor
        lbUseBrowserTitle.textColor = viewUseApp.backgroundColor
        lbUseBrowserDesc.textColor = viewUseApp.backgroundColor

        NotificationCenter.default.post(name:.Notify_APPMODECHANGED, object: nil)
    }
    
    func collapseCredential(){
        if(bCollapse){
            btnCollapse.setTitle("▼", for: .normal)
        }
        else{
            btnCollapse.setTitle("▲", for: .normal)
        }
        viewCredential.isHidden = bCollapse
        
    }
}

