//
//  MaintncVC.swift
//  BuildSourced
//
//  Created by Chance on 5/5/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD


class MaintncVC: BaseVC {

    weak var curAsset: Asset!
    public var updateDelgator: UpdateDelegate!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var scrMain: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var swMaintnceFlag: UISwitch!
    @IBOutlet weak var txtNotes: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomTitle("Maintenance")
        showSettingItems()
        self.swMaintnceFlag.isOn = curAsset.maintenanceFlag
        self.txtNotes.text = curAsset.lastNotesEntry
        // Do any additional setup after loading the view.
        viewContent.layer.cornerRadius = 10
        viewContent.layer.masksToBounds = false
        initCamera()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initCamera(){
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            view.bringSubview(toFront: scrMain)
            // Start video capture
            captureSession?.startRunning()
            
            // Move the message label to the top view
            //view.bringSubview(toFront: messageLabel)
            
            // Initialize QR Code Frame to highlight the QR code
            
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

    }

    @IBAction func onTapUpdate(_ sender: AnyObject) {

        if(swMaintnceFlag.isOn != curAsset.maintenanceFlag){
            self.updateDelgator.onUpdateFlag(flag: swMaintnceFlag.isOn)
        }
    
        if(curAsset.lastNotesEntry?.compare(txtNotes.text!) != .orderedSame){
            self.updateDelgator.onUpdateNotes(notes: txtNotes.text!)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }


}
