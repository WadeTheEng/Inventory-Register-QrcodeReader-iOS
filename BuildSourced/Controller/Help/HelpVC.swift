//
//  HelpVC.swift
//  BuildSourced
//
//  Created by Chance on 5/24/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit

class HelpVC: BaseVC {
    @IBOutlet var wvContent: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomTitle("Help")
        self.showSettingItems()
        wvContent.scalesPageToFit = true
        wvContent.loadRequest(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "help", ofType: "html")!)))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
