//
//  UIViewController+RootVC.swift
//

import Foundation
import UIKit

extension UIViewController {
    // MARK: - Transit Root View Controller
    /**
    Change application's rootview controller with current viewcontroller with CrossDissolve transition
    */
    func setAsRootVCAnimated(){
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        UIView.transition(with: window,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: { () -> Void in
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = self
                UIView.setAnimationsEnabled(oldState)
            },
            completion: nil)
    }
    
    /**
     Set as root view controller
    */
    func setAsRoot(){
        UIApplication.shared.keyWindow?.rootViewController = self
    }
}
