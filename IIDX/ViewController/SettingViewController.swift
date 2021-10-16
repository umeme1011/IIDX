//
//  SettingViewController.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var qproIV: UIImageView!
    @IBOutlet weak var targetPageBtn: UIButton!
    @IBOutlet weak var targetAccountBtn: UIButton!
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var dispSettingBtn: UIButton!
    
    let myUD: MyUserDefaults = MyUserDefaults.init()
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        // クプロ表示
        dispQpro()
        
        // 文言切り替え
        if myUD.getPlayStyle() == Const.Value.PlayStyle.SINGLE {
            targetPageBtn.setTitle("取込対象ページ（SP）", for: .normal)
            targetAccountBtn.setTitle("取込対象アカウント（SP）", for: .normal)
            dispSettingBtn.setTitle("表示設定（SP）", for: .normal)
        } else {
            targetPageBtn.setTitle("取込対象ページ（DP）", for: .normal)
            targetAccountBtn.setTitle("取込対象アカウント（DP）", for: .normal)
            dispSettingBtn.setTitle("表示設定（DP）", for: .normal)
        }
        changeVersionLbl()
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// タッチイベント
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.touchesEnded(touches, with: event)
        
        // メニューエリア以外タップ時、メニューを閉じる
        for touch in touches {
            if touch.view?.tag == 1 {
                closeVC()
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// 左にスワイプ
    @IBAction func swipeLeft(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        closeVC()
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// 閉じる
    private func closeVC() {
        Log.debugStart(cls: String(describing: self), method: #function)
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.settingView.layer.position.x = -self.settingView.frame.width
        },
            completion: { bool in
                self.dismiss(animated: true, completion: nil)
        })
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     CodeCSV登録
     */
    @IBAction func tapLoadCsv(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        let lcc = LoadCodeCsv.init()
        lcc.doLoadCodeCsv()
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     バージョンラベル変更
     */
    public func changeVersionLbl() {
        let ver = "beatmania IIDX "
        switch myUD.getVersion() {
        case 27:
            versionLbl.text = ver + "27 \nHEROIC VERSE"
            versionLbl.textColor = UIColor.magenta
        case 28:
            versionLbl.text = ver + "28 \nBISTROVER"
            versionLbl.textColor = UIColor.blue
        case 29:
            versionLbl.text = ver + "29 \nCastHour"
            versionLbl.textColor = UIColor.orange
        default:
            versionLbl.text = ""
        }
    }
    
    /**
     クプロ表示
     */
    public func dispQpro() {
        let image: UIImage = CommonMethod.loadImage(fileName: Const.Image.Qpro().getQproFileName()) ?? UIImage()
        qproIV.image = image
    }
}
