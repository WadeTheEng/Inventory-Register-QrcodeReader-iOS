//
//  PendingList.swift
//  BuildSourced
//
//  Created by Chance on 5/5/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit

class PendingList: BaseVC {

    @IBOutlet var tblContent: UITableView!
    var btnTitle: UIButton!
    var arrPendings: [Pending]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSettingItems()
        
        tblContent.rowHeight = UITableViewAutomaticDimension
        tblContent.estimatedRowHeight = 66
        
        btnTitle = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        btnTitle.setTitleColor(UIColor.black, for: .normal)
        
        let _pargraph = NSMutableParagraphStyle()
        _pargraph.alignment = .left
        let _attr1: [String : Any] = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: fontRegular(ftSize: 17),NSParagraphStyleAttributeName: _pargraph ]
        let _genTitle = NSMutableAttributedString(string: "Total Pending", attributes: _attr1)
       
        let _attr2: [String : Any] = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: fontBold(ftSize: 15),NSParagraphStyleAttributeName: _pargraph ]
        let _strTitle = NSMutableAttributedString(string: "▼", attributes: _attr2)
        _genTitle.append(_strTitle)
        
        btnTitle.setAttributedTitle(_genTitle, for: .normal)
        btnTitle.titleLabel?.textAlignment = .center
        btnTitle.addTarget(self, action: #selector(onTapTitle), for:.touchUpInside)
        self.navigationItem.titleView = btnTitle
        
        //▾
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(pendingChanged), name: .Notify_PENDINGCHANGED, object: nil)
        pendingChanged()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pendingChanged(){
        arrPendings = DBManager.shared.getAllPending()
        self.tblContent.reloadData()
    }
    

    func onTapTitle(){
        presentTotalPending()
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

extension PendingList: UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - Table View
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrPendings.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let _cellSet: PendingCountCell = tableView.dequeueReusableCell(withIdentifier: "PendingCountCell")! as! PendingCountCell
            _cellSet.lbCount.text = "\(arrPendings.count)"
            
            return _cellSet
        }
        else{
            let _cellSet: PendingItemCell = tableView.dequeueReusableCell(withIdentifier: "PendingItemCell")! as! PendingItemCell
            let _pending = arrPendings[indexPath.row - 1]
            _cellSet.lbTitle.text = _pending.getPendingname()
            _cellSet.lbDate.text = shortDateString(date: _pending.pendDate as! Date)
            return _cellSet
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if(indexPath.row > 0){
            let _pending = arrPendings[indexPath.row - 1]
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

//Mark -

extension PendingList: UIPopoverPresentationControllerDelegate {
    
    func presentTotalPending() {
        let popoverContentController = StoryboardScene.Main.totalPendingVC()
        popoverContentController.view.backgroundColor = UIColor.white
        
        // Set your popover size.
        popoverContentController.preferredContentSize = CGSize(width: 300, height: 300)
        
        // Set the presentation style to modal so that the above methods get called.
        popoverContentController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // Set the popover presentation controller delegate so that the above methods get called.
        popoverContentController.popoverPresentationController!.delegate = self

        // Present the popover.
        self.present(popoverContentController, animated: true, completion: nil)
    }
    
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .up
        let _rectBtn = btnTitle.frame
        popoverPresentationController.backgroundColor = .white
        popoverPresentationController.sourceView = btnTitle
        popoverPresentationController.sourceRect = CGRect(x: 0, y: _rectBtn.origin.y, width: _rectBtn.width, height: _rectBtn.height)
    }
   
    
   
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
}
