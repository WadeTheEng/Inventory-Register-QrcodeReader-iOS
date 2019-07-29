//
//  CustomEdgeButton.swift
//  Discovery
//
//  Created by Chance on 11/25/16.
//  Copyright © 2016 Chance. All rights reserved.
//

import Foundation
import UIKit

class CustomEdgeButton: UIButton{

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleEdgeInsets = UIEdgeInsetsMake(self.titleEdgeInsets.top - 10, self.titleEdgeInsets.left, self.titleEdgeInsets.bottom, self.titleEdgeInsets.right)
    }
    
    
}
