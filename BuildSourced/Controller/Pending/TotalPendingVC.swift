//
//  TotalPendingVC.swift
//  BuildSourced
//
//  Created by Chance on 5/5/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit

class TotalPendingVC: UITableViewController {

    var arrAssets: [Asset]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 66
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector(pendingChanged), name: .Notify_PENDINGCHANGED, object: nil)
        pendingChanged()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pendingChanged(){
        arrAssets = DBManager.shared.getAllAssetsHavePending()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrAssets.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cellSet: TotalPendingCell = tableView.dequeueReusableCell(withIdentifier: "TotalPendingCell")! as! TotalPendingCell
        if(indexPath.row == 0){
            _cellSet.lbTitle.text = "Total Pending"
            _cellSet.lbCount.text = "\(DBManager.shared.getAllPendingCount())"
            _cellSet.lbDate.text = ""
        }
        else{
            let _asset = arrAssets[indexPath.row - 1]
            _cellSet.lbTitle.text = _asset.assetName
            _cellSet.lbCount.text = "\(_asset.getPendingCount())"
            _cellSet.lbDate.text = ""
        }
        
        return _cellSet
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        tableView.deselectRow(at: indexPath, animated: true)
    }


}
