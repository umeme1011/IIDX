//
//  InformationViewController.swift
//  IIDX
//
//  Created by umeme on 2019/09/20.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift
import WebKit

class InformationViewController: UIViewController {
    
    let myUD: MyUserDefaults = MyUserDefaults()
    var scoreRealm: Realm!
    var seedRealm: Realm!

    @IBOutlet weak var verLbl: UILabel!
    @IBOutlet weak var seedDbLbl: UILabel!
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        // アプリバージョン取得
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
            as! String
        verLbl.text = "Ver. \(version)"
        
        // seedDBバージョン設定
        seedDbLbl.text = "Ver. \(Const.Realm.SEED_DB_VER)"
        
        scoreRealm = CommonMethod.createScoreRealm()
        seedRealm = CommonMethod.createSeedRealm()
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// RESETボタン押下
    @IBAction func tapResetBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // 確認アラート表示
        let alert = UIAlertController(title: "", message: Const.Message.RESET_COMFIRM
            , preferredStyle: UIAlertController.Style.alert)

        let okBtn = UIAlertAction(title: Const.Label.OK, style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) -> Void in
            
            // DB全TBL削除
            try! self.scoreRealm.write {
                self.scoreRealm.deleteAll()
            }
            // UserDefaults全初期化
            self.myUD.initAll()
            
            // クプロ画像を削除
            let path = CommonMethod.fileInDocumentsDirectory(filename: Const.Image.Qpro.FILE_NAME)
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                Log.error(cls: String(describing: self), method: #function, msg: "クプロファイル削除エラー")
            }
            
            // Cookieを削除
            LoginViewController.removeCookie()
            
            // 初期処理
            self.myUD.setInitFlg(flg: true)
            let ini: Init = Init.init()
            _ = ini.doInit()

            // データ取得処理
            let vc: MainViewController
                = self.presentingViewController?.presentingViewController as! MainViewController
            let operation: Operation = Operation.init(mainVC: vc)
            let score: Results<MyScore> = operation.doOperation()
            // メイン画面のUI処理
            vc.mainUI()
            // リスト画面リロード
            let listVC: ListViewController
                = self.presentingViewController?.presentingViewController?.children[0] as! ListViewController
            listVC.scores = score
            listVC.listTV.reloadData()
            
            // 完了アラート表示
            CommonMethod.dispAlert(message: Const.Message.RESET_COMPLETE, vc: self)
        })
        let cancelBtn = UIAlertAction(title: Const.Label.CANCEL, style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
        self.present(alert, animated: false, completion: nil)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /// Doneボタン押下
    @IBAction func tapDoneBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    /// Backボタン押下
    @IBAction func tapBackBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    /// 右にスワイプ
    @IBAction func swipeRight(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
}
