//
//  UIAlertController+Rx.swift

import Foundation
import UIKit

typealias AlertControllerResult = (style:UIAlertActionStyle, buttonIndex:Int)

extension UIAlertController {
    /**
     Creates an UIAlertController instance with options and call back configured in parameter, Can use UIViewController's showAlerController: function to present it.
     */
    class func alertWithTitle(title:String?, message:String?, cancelTitle ct:String?, destructiveTitle dt:String?, otherTitles:[String], callback:((AlertControllerResult) -> Void)?) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let ct = ct {
            let cancelAction = UIAlertAction(title: ct, style: .cancel){ _ in
                callback?((.cancel, 0))
            }
            alert.addAction(cancelAction)
        }
        
        if let dt = dt {
            let destructiveAction =  UIAlertAction(title: dt, style: .destructive){ _ in
                callback?((.destructive, 0))
            }
            alert.addAction(destructiveAction)
        }
        
        for (index, title) in otherTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default){ _ in
                callback?((.default, index))
            }
            alert.addAction(action)
        }
        return alert
    }
    
    /**
     Creates an UIAlertController instance with options and call back configured in parameter, Can use UIViewController's showAlerController: function to present it.
     */
    class func alertWithTitle(title:String?, message:String?, cancelTitle ct:String?, otherTitles:[String], callback:((AlertControllerResult) -> Void)?) -> UIAlertController {
        return alertWithTitle(title: title, message: message, cancelTitle: ct, destructiveTitle: nil, otherTitles: otherTitles, callback: callback)
    }
    
    /**
     Creates an UIAlertController instance with options and call back configured in parameter, Can use UIViewController's showAlerController: function to present it.
     */
    class func alertWithMessage(message:String?, cancelTitle ct:String?, otherTitles:[String], callback:((AlertControllerResult) -> Void)?) -> UIAlertController {
        return alertWithTitle(title: nil, message: message, cancelTitle: ct, destructiveTitle: nil, otherTitles: otherTitles, callback: callback)
    }
    
    /**
     Creates an UIAlertController instance with options and call back configured in parameter, Can use UIViewController's showAlerController: function to present it.
     */
    class func alertWithMessage(message:String?, cancelTitle ct:String, callback:((AlertControllerResult) -> Void)? = nil) -> UIAlertController{
        return alertWithTitle(title: nil, message: message, cancelTitle: ct, destructiveTitle: nil, otherTitles: [], callback: callback)
    }
    
    /**
     Creates an UIAlertController instance with options and call back configured in parameter, Can use UIViewController's showAlerController: function to present it.
     */
    class func alertWithMessage(message:String?, callback:((AlertControllerResult) -> Void)? = nil) -> UIAlertController{
        return alertWithTitle(title: nil, message: message, cancelTitle: "OK".localizedString(), destructiveTitle: nil, otherTitles: [], callback: callback)
    }
    
    /**
     Creates an UIAlertController instance with options and call back configured in parameter, Can use UIViewController's showAlerController: function to present it.
     */
    class func alertWithTitle(title:String?, message:String?, callback:((AlertControllerResult) -> Void)? = nil) -> UIAlertController{
        return alertWithTitle(title: title, message: message, cancelTitle: "OK".localizedString(), destructiveTitle: nil, otherTitles: [], callback: callback)
    }
    
    /**
     Creates an UIAlertController instance with options and call back configured in parameter, Can use UIViewController's showAlerController: function to present it.
     */
    class func alertWithTitle(title:String?, message:String?, cancelTitle ct:String?, callback:((AlertControllerResult) -> Void)? = nil) -> UIAlertController{
        return alertWithTitle(title: title, message: message, cancelTitle: ct, destructiveTitle: nil, otherTitles: [], callback: callback)
    }
}
