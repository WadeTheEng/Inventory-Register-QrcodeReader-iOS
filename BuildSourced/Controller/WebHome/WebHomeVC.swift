//
//  WebHomeVC.swift
//  BuildSourced
//
//  Created by Chance on 5/24/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit
import SVProgressHUD

extension String {
    
    var RFC3986UnreservedEncoded:String {
        let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._/:"
        let unreservedCharsSet: CharacterSet = CharacterSet(charactersIn: unreservedChars)
        let encodedString: String = self.addingPercentEncoding(withAllowedCharacters: unreservedCharsSet)!
        return encodedString
    }
}


class WebHomeVC: BaseVC,UIWebViewDelegate{
    
    @IBOutlet var wvContent: UIWebView!
    var strURL:String = "firstTimeThrough"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomTitle("Home")
        self.showSettingItems()
        wvContent.delegate = self
        wvContent.scalesPageToFit = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func handleUrl(_ aUrl: String){
        SVProgressHUD.dismiss()
        strURL = aUrl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //on the first launch, url will have no value... set it to the website
        print(strURL)
        if(!strURL.contains("http")) {
            let theUrl = URL (string: URL_Server)
            let requestObj = URLRequest(url: theUrl!)
            
            wvContent.loadRequest(requestObj)
        } else if (strURL.contains("buildsourced.com")) {
            return;
        }
        else {
            let escapedString = strURL.RFC3986UnreservedEncoded
            let query = escapedString.replacingOccurrences(of: "%0D", with: "", options: .regularExpression)
            print(query)
            let theUrl = URL (string: query)
            let requestObj = URLRequest(url: theUrl!)
            wvContent.loadRequest(requestObj)
        }
        
    }
    

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // let urlScheme = request.url?.scheme
        print("in webView: " + (request.url?.absoluteString)!)
        
        if(request.url?.absoluteString == "https://www.buildsourced.com/users/sign_in") {
            
            //first grab the user name, pwd and the Remember Me checkbox
            let username = webView.stringByEvaluatingJavaScript(from: "document.getElementById('user_email').value")
            let password = webView.stringByEvaluatingJavaScript(from: "document.getElementById('user_password').value")
            let checked = webView.stringByEvaluatingJavaScript(from: "document.getElementById('user_remember_me').checked" )
            
            
            print("username: " + username!)
            print("password: " + password!)
            print("checked: " + checked!)
            
            //now if the user has checked the Remember me box, we want to save their information
            //if((checked!.contains("true")) && username!.contains("@") && !password!.isEmpty) {
            if((checked!.contains("true"))) {
                print("we'll want to save these parameters " + username! + " password: " + password!)
                
                // Setting user name, password and checkbox settings to safe store them
                let defaults = UserDefaults.standard
                
                defaults.set(username, forKey: keyUserEmail)
                defaults.set(password, forKey: keyUserPasswd)
                defaults.set("true", forKey: "checkbox")
                
                
            } else {
                // Setting user name, password and checkbox settings to safe store them
                let defaults = UserDefaults.standard
                //this function gets called twice - once when entering the page and once upon leaving
                //the first time through the username and password will already be empty
                //we don't want to remove valid info in the safe store on the first time through
                if(!(username?.isEmpty)! && !(password?.isEmpty)!) {
                    defaults.set("", forKey: keyUserEmail)
                    defaults.set("", forKey: keyUserPasswd)
                    defaults.set("false", forKey: "checkbox")
                }
                print("we'll not want to save these parameters")
            }
            
            
        }
        
        return true
        
    }
    
    
    //checks whether the key exists in user defaults
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    //in this function we're looking at the URLs being loaded
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        //test
        //changeTabBar(hidden: false, animated: true)
        SVProgressHUD.dismiss()
        print("webViewDidFinishLoad")
        
        handleUrl((webView.request?.mainDocumentURL?.absoluteString)!)
        
        print(webView.request?.mainDocumentURL?.absoluteString ?? "No URL specified ")
        //if the URL loaded is the sign_in URL for BuildSourced, we want the option to fill in the password
        //that is, if the user has checked Remember Me
        if(webView.request?.mainDocumentURL?.absoluteString == "https://www.buildsourced.com/users/sign_in") {
            print("match!")
            
            //first figure out whether the "Remember Me" flag was set last time
            let defaults = UserDefaults.standard
            
            //grab the stored checkbox
            let checkbox = defaults.string(forKey: "checkbox")
            
            //does the checkbox key exist?
            if(isKeyPresentInUserDefaults(key: "checkbox")) {
                //if the checkbox was turned on, then read in the variables from safe store and set checkbox
                if(checkbox!.contains("true")) {
                    let savedUsername = defaults.string(forKey: keyUserEmail)
                    let savedPassword = defaults.string(forKey: keyUserPasswd)
                    
                    if(isKeyPresentInUserDefaults(key: keyUserEmail) && isKeyPresentInUserDefaults(key: keyUserPasswd)) {
                        let fillForm = String(format: "document.getElementById('user_email').value = '\(savedUsername!)';document.getElementById('user_password').value = '\(savedPassword!)';")
                        
                        webView.stringByEvaluatingJavaScript(from: fillForm)
                        //check the checkbox
                        webView.stringByEvaluatingJavaScript(from: "document.getElementById('user_remember_me').checked = true;" )
                    }
                } else { //if the check box is turned off, set fields to blank and checkbox to false
                    let fillForm = String(format: "document.getElementById('user_email').value = '';document.getElementById('user_password').value = '';")
                    
                    webView.stringByEvaluatingJavaScript(from: fillForm)
                    //uncheck the checkbox
                    webView.stringByEvaluatingJavaScript(from: "document.getElementById('user_remember_me').checked = false;" )
                    
                }//if the user did not save uname and pwd
            }//if checkbox is empty
        }//if webview request matches buildsourced.com
    }


}

extension WebHomeVC{
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("did scroll")
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        print("begin dragging")
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0{
            changeTabBar(hidden: true, animated: true)
        }
        else{
            changeTabBar(hidden: false, animated: true)
        }
    }
    
    func changeTabBar(hidden:Bool, animated: Bool){
        let tabBar = self.tabBarController?.tabBar
        if tabBar!.isHidden == hidden{ return }
        let frame = tabBar?.frame
        let offset = (hidden ? (frame?.size.height)! : -(frame?.size.height)!)
        let duration:TimeInterval = (animated ? 0.5 : 0.0)
        tabBar?.isHidden = false
        if frame != nil
        {
            UIView.animate(withDuration: duration,
                           animations: {tabBar!.frame = frame!.offsetBy(dx: 0, dy: offset)},
                           completion: {
                            
                            if $0 {tabBar?.isHidden = hidden}
            })
        }
    }
}
