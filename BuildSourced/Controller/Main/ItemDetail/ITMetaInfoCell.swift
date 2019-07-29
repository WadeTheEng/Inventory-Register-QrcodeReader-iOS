//
//  PendingCountCell.swift
//  BuildSourced
//
//  Created by Chance on 5/5/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit

class ITMetaInfoCell: UITableViewCell {

    @IBOutlet var lbAssetID: UILabel!
    @IBOutlet var lbLatLang: UILabel!
    @IBOutlet var lbDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
