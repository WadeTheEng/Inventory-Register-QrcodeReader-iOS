//
//  LatLngPendingCell.swift
//  BuildSourced
//
//  Created by Chance on 5/5/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit

class LatLngPendingCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbAssetID: UILabel!
    @IBOutlet weak var lbLatLng: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
