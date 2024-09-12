//
//  DetailTableViewCell.swift
//  IIDX
//
//  Created by umeme on 2019/09/06.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var djNameLbl: UILabel!
    @IBOutlet weak var djLevelIV: UIImageView!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var clearLumpLbl: UILabel!
    @IBOutlet weak var missCntLbl: UILabel!
    @IBOutlet weak var clearLumpIV: UIImageView!
    @IBOutlet weak var plusMinusLbl: UILabel!
    
    override func awakeFromNib() {
//        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

    }
}
