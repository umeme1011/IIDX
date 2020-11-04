//
//  DispViewController.swift
//  IIDX
//
//  Created by umeme on 2020/11/04.
//  Copyright © 2020 umeme. All rights reserved.
//

import UIKit

class DispViewController: UIViewController {
    
    @IBOutlet weak var ghostOnIV: UIImageView!
    @IBOutlet weak var ghostOffIV: UIImageView!
    @IBOutlet weak var ghostDispView: UIView!
    
    let myUD: MyUserDefaults = MyUserDefaults()
    var ghostDispFlg = false
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        // 前作ゴースト表示設定はバージョン27では設定不可
        if myUD.getVersion() == Const.Version.START_VERSION_NO {
            ghostDispView.isHidden = false
        } else {
            ghostDispView.isHidden = true
        }
        
        // 前作ゴースト表示フラグ取得
        ghostDispFlg = myUD.getGhostDispFlg()
        if ghostDispFlg {
            ghostOnIV.image = UIImage(systemName: Const.Image.CHECK)
            ghostOffIV.image = nil
        } else {
            ghostOnIV.image = nil
            ghostOffIV.image = UIImage(systemName: Const.Image.CHECK)
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     前作ゴースト表示ありボタン押下
     */
    @IBAction func tapGhostOnBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)

        ghostOffIV.image = nil
        ghostOnIV.image = UIImage(systemName: Const.Image.CHECK)
        ghostDispFlg = true
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     前作ゴースト表示なしボタン押下
     */
    @IBAction func tapGhostOffBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)

        ghostOffIV.image = UIImage(systemName: Const.Image.CHECK)
        ghostOnIV.image = nil
        ghostDispFlg = false
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     Backボタン押下
     */
    @IBAction func tapBackBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    /**
     Doneボタン押下
     */
    @IBAction func tapDoneBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)

        myUD.setGhostDispFlg(flg: ghostDispFlg)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
}
