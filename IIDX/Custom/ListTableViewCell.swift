//
//  ListTableViewCell.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var clearLumpIV: UIImageView!
    @IBOutlet weak var djLevelIV: UIImageView!
    @IBOutlet weak var levelLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var missLbl: UILabel!
    @IBOutlet weak var scoreRateLbl: UILabel!
    @IBOutlet weak var plusMinusLbl: UILabel!
    @IBOutlet weak var ghostScoreLbl: UILabel!
    @IBOutlet weak var ghostScoreRateLbl: UILabel!
    @IBOutlet weak var ghostMissLbl: UILabel!
    @IBOutlet weak var ghostPlusMinusLbl: UILabel!
    
    override func awakeFromNib() {
//        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
    }
}
