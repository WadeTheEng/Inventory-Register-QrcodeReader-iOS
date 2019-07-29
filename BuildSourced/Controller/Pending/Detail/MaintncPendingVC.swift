//
//  MaintncPendingVC.swift
//  BuildSourced
//
//  Created by Chance on 5/5/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit

class MaintncPendingVC: BaseVC {

    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var tblContent: UITableView!
    public var curPending: Pending!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbSubTitle.text = curPending.getPendingname()
        lbDate.text = shortDateString(date: curPending.pendDate as! Date)
        tblContent.rowHeight = UITableViewAutomaticDimension
        tblContent.estimatedRowHeight = 66
        setCustomTitle("Pending")
        showSettingItems()
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

extension MaintncPendingVC: UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - Table View
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cellSet: MaintncPendingCell = tableView.dequeueReusableCell(withIdentifier: "MaintncPendingCell")! as! MaintncPendingCell
        _cellSet.lbTitle.text = curPending.parentAsset!.assetName// "Palmer Dumpster with long..."
        _cellSet.lbAssetID.text = "Asset ID: \(curPending.parentAsset!.assetId)"
        _cellSet.lbMaintncCont.text = curPending.parentAsset!.lastNotesEntry
        _cellSet.swMaintnc.isOn = curPending.maintenanceFlag
        return _cellSet
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

