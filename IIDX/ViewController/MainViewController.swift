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
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)

        // 進捗View非表示
        progressView.alpha = 0.0
        
        // 起動時初期処理
        Init.doInit()
        
        // UI処理
        mainUI()
        
        Log.debugEnd(cls: String(describing: self), method: #function)
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
        
//        // 取り込みボタン、編集ボタン切り替え
//        if myUD.getMode() == Const.Value.Mode.EDIT_MODE {
//            importBtn.setImage(UIImage(named: Const.Image.Operation.EDIT), for: .normal)
//        } else {
//            importBtn.setImage(UIImage(named: Const.Image.Operation.IMPORT), for: .normal)
//        }
        
        
//        firstLoadFlg = myUD.getFirstLoadFlg()
//        if firstLoadFlg {
//            // 未取込の場合はボタンを無効化する
//            filterBtn.isEnabled = false
//            filterBtn.setImage(UIImage(named: Const.Image.Operation.FILTER_NG), for: .normal)
//            sortBtn.isEnabled = false
//            sortBtn.setImage(UIImage(named: Const.Image.Operation.SORT_NG), for: .normal)
//            statisticsBtn.isEnabled = false
//            statisticsBtn.setImage(UIImage(named: Const.Image.Operation.STATISTICS_NG), for: .normal)
//            // 説明バルーンを表示
//            balloonLbl.isHidden = false
//            balloonIV.isHidden = false
//            balloonLbl.text = Const.Message.IMPORT_BALLOON
//            balloonLbl.textColor = UIColor.darkGray
//        } else {
//            filterBtn.isEnabled = true
//            filterBtn.setImage(UIImage(named: Const.Image.Operation.FILTER_OK), for: .normal)
//            sortBtn.isEnabled = true
//            sortBtn.setImage(UIImage(named: Const.Image.Operation.SORT_OK), for: .normal)
//            statisticsBtn.isEnabled = true
//            statisticsBtn.setImage(UIImage(named: Const.Image.Operation.STATISTICS_OK), for: .normal)
//            balloonLbl.isHidden = true
//            balloonIV.isHidden = true
//        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}
