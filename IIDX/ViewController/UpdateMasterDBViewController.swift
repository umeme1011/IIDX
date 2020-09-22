//
//  UpdateMasterDBViewController.swift
//  IIDX
//
//  Created by umeme on 2020/09/15.
//  Copyright © 2020 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class UpdateMasterDBViewController: UIViewController {
    
    @IBOutlet weak var lastUpdLbl: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let myUD: MyUserDefaults = MyUserDefaults.init()
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        // 最終更新日時ラベル
        lastUpdLbl.text = "最終更新日時：\(myUD.getLastUpdateMasterDB())"
        
        indicatorView.isHidden = true
        indicator.hidesWhenStopped = true
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    @IBAction func tapUpdateBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // インジケータ表示
//        startIndicator()
        indicatorView.isHidden = false
        indicator.startAnimating()

        let umd: UpdateMasterDB = UpdateMasterDB.init()
        
        let dispatchQueue: DispatchQueue = DispatchQueue(label: "wiki update Thread")
        dispatchQueue.async() {
            Log.debugStart(cls: String(describing: self), method: #function + "Thread")

            // wikiデータ取り込み
            umd.doUpdate()
            
            DispatchQueue.main.async {
                // 更新ありの場合
                if umd.updFlg {
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
                    
                    // 最終更新日時更新
                    let dateString = self.getDateString(date: Date())
                    self.lastUpdLbl.text = "最終更新日時：\(dateString)"
                    self.myUD.setLastUpdateMasterDB(date: dateString)
                }
            
                // インジケータ非表示
                self.indicatorView.isHidden = true
                self.indicator.stopAnimating()
                // アラート表示
                CommonMethod.dispAlert(message: umd.msg, vc: self)
            }
            Log.debugEnd(cls: String(describing: self), method: #function + "Thread")
        }
        
        
//        // wikiデータ取り込み
//        let umd: UpdateMasterDB = UpdateMasterDB.init()
//        umd.doUpdate()
//
//        // 更新ありの場合
//        if umd.updFlg {
//            // データ取得処理
//            let vc: MainViewController
//                = self.presentingViewController?.presentingViewController as! MainViewController
//            let operation: Operation = Operation.init(mainVC: vc)
//            let score: Results<MyScore> = operation.doOperation()
//            // メイン画面のUI処理
//            vc.mainUI()
//            // リスト画面リロード
//            let listVC: ListViewController
//                = self.presentingViewController?.presentingViewController?.children[0] as! ListViewController
//            listVC.scores = score
//            listVC.listTV.reloadData()
//
//            // 最終更新日時更新
//            let dateString = getDateString(date: Date())
//            lastUpdLbl.text = "最終更新日時：\(dateString)"
//            myUD.setLastUpdateMasterDB(date: dateString)
//        }
//
//        // インジケータ非表示
////        dismissIndicator()
//        indicatorView.isHidden = true
//        indicator.stopAnimating()
//
//        // アラート表示
//        CommonMethod.dispAlert(message: umd.msg, vc: self)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    @IBAction func tapBackBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tapDoneBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
     現在日時を取得（yyyy/MM/dd HH:mm:ss）
     */
    private func getDateString(date: Date) -> String{
        let locale = Locale.current.identifier
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        f.locale = Locale(identifier: locale)
        return f.string(from: date)
    }
}
