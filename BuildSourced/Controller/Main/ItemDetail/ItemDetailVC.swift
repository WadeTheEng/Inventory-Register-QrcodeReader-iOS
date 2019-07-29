//
//  ItemDetailVC.swift
//  BuildSourced
//
//  Created by Chance on 5/6/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit

class ItemDetailVC: BaseVC {
    var nTblCount : Int = 0
    @IBOutlet weak var tblContent: UITableView!
    public var curAsset: Asset!
    var arrPending: [Pending]!

    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomTitle(curAsset.assetName!)
        showSettingItems()
        tblContent.rowHeight = UITableViewAutomaticDimension
        tblContent.estimatedRowHeight = 66
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPending), name: .Notify_PENDINGCHANGED, object: nil)
        refreshPending()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshPending(){
        arrPending = curAsset.getPendingArray()
        self.tblContent.reloadData()
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

extension ItemDetailVC: UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - Table View
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nTblCount = 5 + curAsset.getPendingCount()
        return nTblCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let _cellSet: ITTitleCell = tableView.dequeueReusableCell(withIdentifier: "ITTitleCell")! as! ITTitleCell
            _cellSet.lbTitle.text = curAsset.assetName
            //"Palmer Dumpster if it has a long name on this screen"
            return _cellSet
        }
        else if(indexPath.row == 1){
            let _cellSet: ITImageCell = tableView.dequeueReusableCell(withIdentifier: "ITImageCell")! as! ITImageCell
            _cellSet.arrImages = curAsset.imageUrls
            return _cellSet
        }
        else if(indexPath.row == 2){
            let _cellSet: ITMetaInfoCell = tableView.dequeueReusableCell(withIdentifier: "ITMetaInfoCell")! as! ITMetaInfoCell
            _cellSet.lbAssetID.text = "Asset ID: "+"\(curAsset.assetId)"
            _cellSet.lbLatLang.text = "Lat:\(curAsset.latitude),Lng:\(curAsset.longitude)"
            _cellSet.lbDescription.text = curAsset.assetDescription
            return _cellSet
        }
        else if(indexPath.row == 3){
            let _cellSet: ITMaintncInfoCell = tableView.dequeueReusableCell(withIdentifier: "ITMaintncInfoCell")! as! ITMaintncInfoCell
            _cellSet.swMaintncRequired.isOn = curAsset.maintenanceFlag
            _cellSet.lbMaintncNotes.text = curAsset.lastNotesEntry
            return _cellSet

        }
        else if(indexPath.row == 4){
            let _cellSet: ITPendingCountCell = tableView.dequeueReusableCell(withIdentifier: "ITPendingCountCell")! as! ITPendingCountCell
            _cellSet.lbCurPendCount.text = "\(curAsset.pendings!.count)"
            _cellSet.lbTotalPendCount.text = "\(DBManager.shared.getAllPendingCount())"
            return _cellSet
        }
        else{
            let _cellSet: PendingItemCell = tableView.dequeueReusableCell(withIdentifier: "PendingItemCell")! as! PendingItemCell
            let _pending = arrPending[indexPath.row - 5]
            _cellSet.delegate = self
            _cellSet.lbTitle.text = _pending.getPendingname()
            _cellSet.lbDate.text = shortDateString(date: _pending.pendDate as! Date)
            
            return _cellSet
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if(indexPath.row >= 5){
            let _pending = arrPending[indexPath.row - 5]
            switch _pending.pendKind {
            case 0,1:
                let _vcPend = StoryboardScene.Main.latLngPendingVC()
                _vcPend.curPending = _pending
                self.navigationController?.pushViewController(_vcPend, animated: true)
            case 3,4:
                let _vcPend = StoryboardScene.Main.maintncPendingVC()
                _vcPend.curPending = _pending
                self.navigationController?.pushViewController(_vcPend, animated: true)
            default:
                let _vcPend = StoryboardScene.Main.imageAddedPendingVC()
                _vcPend.curPending = _pending
                self.navigationController?.pushViewController(_vcPend, animated: true)
            }

        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}

extension ItemDetailVC: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        
        if orientation == .left {
            
             let cell = tableView.cellForRow(at: indexPath) as! PendingItemCell
            let delete = SwipeAction(style: .destructive, title: nil) {[weak self] action, indexPath in
                //cell.hideSwipe(animated: true)
                
                //self.arrPending.remove(at: indexPath.row - 5)
                guard let strongSelf = self else {
                    return
                }
                let _pending = strongSelf.arrPending[indexPath.row - 5]
                DBManager.shared.deletePending(aPending: _pending)
                
            }
        
            delete.title = "Trash"
            delete.image = UIImage(named:"icon_trash")
            delete.backgroundColor = UIColor(named: .AppRed)
            delete.hidesWhenSelected = true
            return [delete]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        //options.expansionStyle = .destructive
        options.transitionStyle = SwipeTableOptions().transitionStyle
        options.buttonPadding = 8
        options.buttonSpacing = 1
        return options
    }
    


}
