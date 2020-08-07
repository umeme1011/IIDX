//
//  EditListTableViewCell.swift
//  IIDX
//
//  Created by umeme on 2019/10/10.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit

class EditListTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var clearLumpIV: UIImageView!
    @IBOutlet weak var djLevelIV: UIImageView!
    @IBOutlet weak var levelLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var missLbl: UILabel!
    @IBOutlet weak var scoreRateLbl: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
