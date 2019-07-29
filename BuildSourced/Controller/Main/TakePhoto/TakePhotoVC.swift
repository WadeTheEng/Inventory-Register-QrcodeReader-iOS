//
//  TakePhotoVC.swift
//  BuildSourced
//
//  Created by Chance on 5/11/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit
import SVProgressHUD

class TakePhotoVC: BaseVC,TWCameraViewDelegate {
    
    public var updateDelgator: UpdateDelegate!
    
    @IBOutlet weak var viewPreview: UIView!
    @IBOutlet weak var ivPreview: UIImageView!
    var cameraView: TWCameraView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomTitle("Camera")
        showSettingItems()
        
        cameraView = TWCameraView(frame: self.view.frame)
        cameraView.delegate = self
        self.view.addSubview(cameraView)
        self.view.sendSubview(toBack: cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.autoPinEdge(toSuperviewEdge: .leading)
        cameraView.autoPinEdge(toSuperviewEdge: .trailing)
        cameraView.autoPinEdge(toSuperviewEdge: .top)
        cameraView.autoPinEdge(toSuperviewEdge: .bottom)
 
        cameraView.startPreview(requestPermissionIfNeeded: true)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapTakePhoto(){
       
        cameraView.capturePhoto()
        /*viewPreview.isHidden = false//debug
        if(Int(Date().timeIntervalSince1970) % 2 == 0){
            ivPreview.image = UIImage(named: "bg_spalsh")
        }
        else{
            ivPreview.image = UIImage(named: "btn_wrench")
        }*/
        
    }
    
    @IBAction func onTapAddImage(){
        self.updateDelgator.onUpdatePhoto(image: ivPreview.image!)
        cameraView.stopPreview()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapReTake(){
        viewPreview.isHidden = true
        self.view.sendSubview(toBack: viewPreview)
    }
    
    func cameraViewDidCaptureImage(image: UIImage, cameraView: TWCameraView){
        viewPreview.isHidden = false
        self.view.bringSubview(toFront: viewPreview)
        ivPreview.image = image
    }
    
    func cameraViewDidFailToCaptureImage(error: Error, cameraView: TWCameraView){
        //viewPreview.isHidden = false
        _ = UIAlertController.alertWithMessage(message: error.localizedDescription)
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
