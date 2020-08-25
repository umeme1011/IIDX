//
//  MainViewController.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressLbl: UILabel!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var sortBtn: UIButton!
    @IBOutlet weak var statisticsBtn: UIButton!
    @IBOutlet weak var importBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var playStyleBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var balloonIV: UIImageView!
    @IBOutlet weak var balloonLbl: UILabel!
    
    let myUD: MyUserDefaults = MyUserDefaults()
    var firstLoadFlg: Bool!
    var cancelFlg: Bool = false
    var alertMsg: String = ""
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)

        // 進捗View非表示
        progressView.alpha = 0.0
        
        // 起動時初期処理
        alertMsg = Init.doInit()
        
        // UI処理
        mainUI()
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if alertMsg != "" {
            // 取り込み完了アラート表示
            let vc: UIViewController = CommonMethod.getTopViewController() ?? UIViewController()
            CommonMethod.dispAlert(message: alertMsg, vc: vc)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        Log.debugStart(cls: String(describing: self), method: #function)

        switch segue.identifier {
            
        // リスト画面へ
        case Const.Segue.TO_LIST:
            // 遷移先のVC取得
            let vc:ListViewController = segue.destination as? ListViewController ?? ListViewController()
            vc.mainVC = self

        // ログイン画面へ
        case Const.Segue.TO_LOGIN:
            // 遷移先のVC取得
            let vc:LoginViewController = segue.destination as? LoginViewController ?? LoginViewController()
            vc.mainVC = self
            
        // 選択編集画面へ
        case Const.Segue.TO_EDIT_SELECT:
            // 遷移先のVC取得
            let vc:EditSelectViewController
                = segue.destination as? EditSelectViewController ?? EditSelectViewController()
//            vc.mainVC = self
            let list: ListViewController = self.children[0] as! ListViewController
            vc.editScoreArray = list.editScoreArray
            vc.scores = list.scores
            
        default:
            return
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// 取り込みボタン押下
    @IBAction func tapImportBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
//        let mode: Int = myUD.getMode()
//
//        // 編集モード
//        if mode == Const.Value.Mode.EDIT_MODE {
//            // 選択編集画面へ遷移
//            self.performSegue(withIdentifier: Const.Segue.TO_EDIT_SELECT, sender: nil)
//
//        // 取り込みモード
//        } else {
            // ２回め以降、アカウントにチェックが入っていない場合はアラート表示して何もしない
            let target: String = myUD.getTarget()
            let firstLoadFlg: Bool = myUD.getFirstLoadFlg()
            if target.isEmpty && !firstLoadFlg {
                CommonMethod.dispAlert(message: Const.Message.NO_TARGET_ACCOUNT, vc: self)
                return
            }
            
            if CommonData.Import.loadingFlg {
                // 取込中はボタン押下でキャンセル
                cancelFlg = true
            } else {
                // ログイン画面へ遷移
                self.performSegue(withIdentifier: Const.Segue.TO_LOGIN, sender: nil)
            }
//        }

        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// プレイスタイルボタン押下
    @IBAction func tapPlayStyleBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // プレイスタイル切り替え
        if myUD.getPlayStyle() == Const.Value.PlayStyle.SINGLE {
            myUD.setPlayStyle(playStyle: Const.Value.PlayStyle.DOUBLE)
            playStyleBtn.setTitle(Const.Label.DP, for: .normal)
        } else {
            myUD.setPlayStyle(playStyle: Const.Value.PlayStyle.SINGLE)
            playStyleBtn.setTitle(Const.Label.SP, for: .normal)
        }
        
        // 未取り込みの場合はボタン非表示
        mainUI()
        
        // リスト画面リロード
        let operation: Operation = Operation.init(mainVC: self)
        let vc: ListViewController = self.children[0] as! ListViewController
        vc.scores = operation.doOperation()
        vc.listTV.reloadData()
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// 右にスワイプ
    @IBAction func swipeRight(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        // 設定画面へ遷移
        self.performSegue(withIdentifier: Const.Segue.TO_SETTING, sender: nil)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// メイン画面のUI処理
    func mainUI() {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // プレイスタイルボタン
        if myUD.getPlayStyle() == Const.Value.PlayStyle.SINGLE {
            playStyleBtn.setTitle(Const.Label.SP, for: .normal)
        } else {
            playStyleBtn.setTitle(Const.Label.DP, for: .normal)
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}
