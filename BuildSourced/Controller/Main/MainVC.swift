//
//  MainVC.swift
//  BuildSourced
//
//  Created by Chance on 5/2/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import SafariServices
import SVProgressHUD


protocol UpdateDelegate{
    func onUpdateNotes(notes:String)
    func onUpdateFlag(flag:Bool)
    func onUpdatePhoto(image:UIImage)
}

class MainVC: BaseVC, AVCaptureMetadataOutputObjectsDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var btnTopSlide: UIButton!
    @IBOutlet weak var viewScanContent: UIView!
    @IBOutlet weak var viewScannedItem: UIView!
    @IBOutlet weak var lbScannedContent: UILabel!
    var lcLeadingOfScanItem: NSLayoutConstraint!
    var lcBottomOfScanItem: NSLayoutConstraint!
    
    var strPrevCode: String!=""
    var curAsset: Asset?
    var curPlaceMark: CLPlacemark?
    var myLocation:CLLocation? = CLLocation()
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var timeinMS:Int64?
    var stillImageOutput = AVCaptureStillImageOutput()

    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    //instantiate the location manager
    let locationManager = CLLocationManager()
    
    //debug
    /*func perforScan(){
        handleCode(codes: "12345as", type: "")//org.iso.QRCode//http://bsqr1.com/sad
    }*/
 
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession?.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession?.startRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomTitle("BuildSourced")
        showPendingButton()
        showSettingItems()
        //debug 
        //self.perform(#selector(perforScan), with: nil, afterDelay: 2.0)
        //self.perform(#selector(perforScan), with: nil, afterDelay: 2.0)
        
        //initialize time for debounce
        timeinMS = 0
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            print("location service enabled... setting things up")
            locationManager.delegate=self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
            if #available(iOS 9.0, *) {
                print(locationManager.requestLocation())
            } else {
                // Fallback on earlier versions
            }
        }
        
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
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
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession?.startRunning()
            
            // Move the message label to the top view
            //view.bringSubview(toFront: messageLabel)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        // Do any additional setup after loading the view.
    }

    //this function returns the current time in milliseconds
    func currentTimeMillis() -> Int64{
        let nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble*1000)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //messageLabel.text = "No barcode/QR code is detected"
            return
        }
        
        
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.contains(metadataObj.type) {
            //        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            
            if metadataObj.stringValue != nil {
                //check the current time vs the hold time (timeinMS)
                //only proceed if the scan was performed greater than 500 MS after the previous scan
                if(currentTimeMillis() - timeinMS! > 3000 ) {
                    timeinMS=currentTimeMillis()
                    handleCode(codes: metadataObj.stringValue,type: metadataObj.type)
                }
            }
        }
    }
    
    
    
    func handleCode(codes: String,type: String ) {
        
        if(GlobInfo.sharedInstance.isSync){
            return
        }
        
        //guard strPrevCode.compare(codes) != .orderedSame else{ return}
        strPrevCode = codes
        
        let locString = "lat: "  + String(format:"%f",(myLocation?.coordinate.latitude)!) +
            " long: " + String(format:"%f",(myLocation?.coordinate.longitude)!) +
            " altitude: " + String(format:"%f",(myLocation?.altitude)!) + "\n"
        
        var _qrUrl = codes
        // getAddress(latitude: latitude, longitude: longitude)
        curPlaceMark = nil
        getPlacemarkFromLocation(location: myLocation!)
        
        // create a sound ID
        let systemSoundID: SystemSoundID = 1108
        
        // to play sound
        AudioServicesPlaySystemSound (systemSoundID)
        
        //to vibrate
        AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
        
        //messageLabel.text = "Scan Successful\n" + locString
        
        //if the code is a QR code, launch the URL in a browser
        if(type.contains("org.iso.QRCode")) {
            //print("Launching browser")
            _qrUrl = _qrUrl.replacingOccurrences(of: "http", with: "https")
            //UIApplication.shared.openURL(NSURL(string: t)! as URL)
        } else {
            //if the code is a UPC code, then prepend our FQDN and then launch
            _qrUrl = "https://bsqr1.com/" + codes
            //UIApplication.shared.openURL(NSURL(string: s)! as URL)
        }
        let _url = URL(string: _qrUrl)
        if(GlobInfo.sharedInstance.isUseApp){
            
            if let _strRealCodes = _url?.lastPathComponent{
                //print(_strRealCodes)
                if(GlobInfo.sharedInstance.isOnline){
                    SVProgressHUD.show(withStatus: "Syncing")
                    APIManager.apiManager.reqGetAssetWithTokenId(tokenId: _strRealCodes, completionHandler: { [weak self](succ, data) in
                        guard let strongSelf = self else {
                            return
                        }
                        SVProgressHUD.dismiss()
                        let _retData = data["asset_detail"].dictionaryObject
                        if let _assetData = _retData{
                            DBManager.shared.updateAsset(aAsset: _assetData)
                            strongSelf.showScannedDetail(aCodes: _strRealCodes)
                        }
                        else{
                            strongSelf.showScannedDetail(aCodes: _strRealCodes)
                        }
                        
                    })
                }
                else{
                    showScannedDetail(aCodes: _strRealCodes)
                }
            }
        }
        else{
            //let _vcSafari = SFSafariViewController(url: _url!)
            //self.present(_vcSafari, animated: true, completion: nil)
            GlobInfo.sharedInstance.gotoWebHandler(_qrUrl)
        }
        
    }
    
    func takePicture() {
        
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if(self.captureSession?.canAddOutput(stillImageOutput))! {
            self.captureSession?.addOutput(stillImageOutput)
        }
        if let videoConnection = stillImageOutput.connection(withMediaType:AVMediaTypeVideo){
            stillImageOutput.captureStillImageAsynchronously(from:videoConnection, completionHandler: {
                (sampleBuffer, error) in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProvider.init(data: imageData as! CFData)
                let cgImageRef = CGImage.init(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                let image = UIImage.init(cgImage: cgImageRef!, scale: 1.0, orientation: .right)
                // do something with image
                print("I have taken a picture")
                UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil)
                
                
                
            })
        }
        
        
    }
    //this functiong gets called by the getPlacemarkFromLocation function upon callback
    //this function updates the label on the main gui
    func showAddViewController(placemark:CLPlacemark){
        //self.performSegueWithIdentifier("add", sender: placemark)
        //print ("in showAddViewController")
        //print(placemark.name ?? " ")
        
        //messageLabel.text = messageLabel.text! + placemark.name! + " | "
        //messageLabel.text = messageLabel.text! + placemark.locality! + " | "
        //messageLabel.text = messageLabel.text! + placemark.postalCode!
        
    }
    
    //this function is called from the main thread and does a callback to showAddViewController upon Async operation completion
    func getPlacemarkFromLocation(location: CLLocation){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil) {print("reverse geodcode fail: \(error?.localizedDescription)")
                return}
                let pm = placemarks! as [CLPlacemark]
                if pm.count > 0 {
                    self.curPlaceMark = placemarks?[0]
                    //self.showAddViewController(placemark: (placemarks?[0])! as CLPlacemark)
                }
        })
    }
    
    
    
    private func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let userLocation:CLLocation = locations[0] as! CLLocation
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        //Do What ever you want with it
        print(lat)
        print(long)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if #available(iOS 9.0, *) {
                locationManager.requestLocation()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.first != nil {
            // print("location:: (location)")
            myLocation = locations[0]
            
        }
        
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

extension MainVC: UpdateDelegate{
    func onUpdateFlag(flag: Bool) {
        
//        SVProgressHUD.show()
        SVProgressHUD.show(withStatus: "Syncing")
        SyncManager.shared.updateMaintncFlag(flag: flag, aAsset: curAsset!) { [weak self] succ in
            SVProgressHUD.dismiss()
            guard let strongSelf = self else {
                return
            }
            if(succ)
            {
                strongSelf.view.makeSuccessToast("Maintenance Update Successful")
            }
            else{
                strongSelf.view.makeFailedToast("Maintenance Update added to pending updates")
            }
           
        }

    }
    
    func onUpdateNotes(notes: String) {
        
        SVProgressHUD.show(withStatus: "Syncing")
        SyncManager.shared.updateMaintncNotes(notes: notes, aAsset: curAsset!) { [weak self] succ in
            SVProgressHUD.dismiss()
            guard let strongSelf = self else {
                return
            }
            if(succ)
            {
                strongSelf.view.makeSuccessToast("Maintenance Update Successful")
            }
            else{
                strongSelf.view.makeSuccessToast("Maintenance Update added to pending updates")
            }
            
        }
    }
    
    func onUpdatePhoto(image: UIImage) {
        SVProgressHUD.show(withStatus: "Syncing")
        let _imgResized = resizeImage(image: image, newWidth: 800.0)
        if let _imageUpload = _imgResized {
            SyncManager.shared.addPhoto(image: _imageUpload, aAsset: curAsset!) {[weak self] (succ) in
                guard let strongSelf = self else {
                    return
                }
                SVProgressHUD.dismiss()
                
                if(succ){
                    strongSelf.view.makeSuccessToast("Image Update Successful")
                }
                else{
                    strongSelf.view.makeSuccessToast("Image added to pending updates")
                }
            }
        }
        else{
            self.view.makeFailedToast("Image resize failed.")
        }
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        if(image.size.width <= newWidth){
            return image
        }
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension MainVC {
    

    func showScannedDetail(aCodes: String){
        
        curAsset = DBManager.shared.getAsset(aTokenId: aCodes)
        if let _asset = curAsset{
            viewScannedItem.removeFromSuperview()
            let _pargraph = NSMutableParagraphStyle()
            _pargraph.alignment = .left
            let _attr1: [String : Any] = [
                NSForegroundColorAttributeName: UIColor(named:.AppGreen),
                NSFontAttributeName: fontRegular(ftSize: 17),NSParagraphStyleAttributeName: _pargraph ]
            let _genTitle = NSMutableAttributedString(string: "Great job! You have succesfully\ninventoried the asset...\n", attributes: _attr1)
            
            _pargraph.paragraphSpacing = 5
            let _attr2: [String : Any] = [
                NSForegroundColorAttributeName: UIColor.black,
                NSFontAttributeName: fontBold(ftSize: 17),NSParagraphStyleAttributeName: _pargraph ]
            let _strTitle = NSMutableAttributedString(string: _asset.assetName!+"\n", attributes: _attr2)
            
            var _strAddress = ""
            if let _placeMark = curPlaceMark{
                _strAddress = _strAddress + _placeMark.name! + ","
                _strAddress = _strAddress + _placeMark.locality! + ","
                _strAddress = _strAddress + _placeMark.postalCode!
            }
            
            let _latLng = "Lat:" + "\(myLocation!.coordinate.latitude)" + ", Lng:"+"\(myLocation!.coordinate.longitude)"
            if(_strAddress.isEmpty){
                _strAddress = _latLng
            }
            else{
                _strAddress = _strAddress + "\n" + _latLng
            }
            
            let _attr3: [String : Any] = [
                NSForegroundColorAttributeName: UIColor.black,
                NSFontAttributeName: fontRegular(ftSize: 14),NSParagraphStyleAttributeName: _pargraph ]
            let _strDetail = NSMutableAttributedString(string: _strAddress, attributes: _attr3)
            //"Approximate Address: 2045 Lincoln Highway, Edison, NJ\nLat:40.5242, Lng:-74.389"
            _genTitle.append(_strTitle)
            _genTitle.append(_strDetail)
            
            lbScannedContent.attributedText = _genTitle
            
            btnTopSlide.isHidden = true
            viewScanContent.layer.cornerRadius = 10
            viewScanContent.layer.masksToBounds = false
            let _height = _genTitle.height(withConstrainedWidth: self.view.frame.size.width) + 180
            self.view.addSubview(viewScannedItem)
            viewScannedItem.translatesAutoresizingMaskIntoConstraints = false
            lcBottomOfScanItem = viewScannedItem.autoPinEdge(.bottom, to: .bottom, of: self.view, withOffset: 10)
            lcLeadingOfScanItem = viewScannedItem.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: self.view.frame.size.width)
            viewScannedItem.autoSetDimension(.width, toSize: self.view.frame.size.width)
            viewScannedItem.autoSetDimension(.height, toSize: _height)
            self.view.layoutIfNeeded()
            
            //location update
            SyncManager.shared.updateLat(lat: myLocation!.coordinate.latitude, aAsset: _asset)
            SyncManager.shared.updateLng(lng: myLocation!.coordinate.latitude, aAsset: _asset)
            
            UIView.animate(withDuration: 0.5) {
                self.lcLeadingOfScanItem.constant = 0
                self.view.layoutIfNeeded()
            }
        }
        else{
            self.view.makeFailedToast("Can't find the assets.")
        }
    }
    
    @IBAction func onTapCapture(){
        let _takePhotoVC = StoryboardScene.Main.takePhotoVC()
        _takePhotoVC.updateDelgator = self
        self.navigationController?.pushViewController(_takePhotoVC, animated: true)
    }
    
    @IBAction func onTapWrench(){
        let _maintncVC = StoryboardScene.Main.maintncVC()
        _maintncVC.curAsset = curAsset!
        _maintncVC.updateDelgator = self
        self.navigationController?.pushViewController(_maintncVC, animated: true)
    }
    
    @IBAction func onTapSeeMore(){
        let _vcSeeMore = StoryboardScene.Main.itemDetailVC()
        _vcSeeMore.curAsset = curAsset!
        self.navigationController?.pushViewController(_vcSeeMore, animated: true)
    }
    
    @IBAction func onTapCloseDetail(){
        UIView.animate(withDuration: 0.5, animations: {
            self.lcBottomOfScanItem.constant = self.viewScannedItem.frame.size.height
            self.view.layoutIfNeeded()
            }) { _bSuccess in
                self.viewScannedItem.removeFromSuperview()
        }
       
    }
    
    @IBAction func onSwipeUp(){
        UIView.animate(withDuration: 0.5) {
             self.lcBottomOfScanItem.constant = 10
            self.btnTopSlide.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onSwipeDown(){
        UIView.animate(withDuration: 0.5 ,animations: {
            self.lcBottomOfScanItem.constant = self.viewScannedItem.frame.size.height - 34
            self.btnTopSlide.isHidden = false
            self.btnTopSlide.alpha = 0.5
            self.view.layoutIfNeeded()
        }){_bSuccess in
            
        }
    }
    
}
