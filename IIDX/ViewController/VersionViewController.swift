//
//  VersionViewController.swift
//  IIDX
//
//  Created by umeme on 2019/09/11.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class VersionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var versionTV: UITableView!
    
    var versions: Results<Code>!
    var myUD: MyUserDefaults = MyUserDefaults()
    var seedRealm: Realm!
    var scoreRealm: Realm!
    var versionNo: Int = 0
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        versionTV.delegate = self
        versionTV.dataSource = self
        
        seedRealm = CommonMethod.createSeedRealm()
        scoreRealm = CommonMethod.createScoreRealm()
        
        // バージョン一覧取得
        versions = seedRealm.objects(Code.self)
            .filter("\(Code.Types.kindCode.rawValue) = %@ and \(Code.Types.code.rawValue) => %@", Const.Value.kindCode.VERSION, Const.Version.START_VERSION_NO)

        // バージョンNo取得
        versionNo = myUD.getVersion()
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    /*
     セルの数を返す
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return versions.count
    }
    
    /*
     セルを返す
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! OperationTableViewCell

        // 項目名
        cell.itemLbl.text = versions[indexPath.row].name
        
        // チェック
        if versions[indexPath.row].code == versionNo {
            cell.checkIV.image = UIImage(systemName: Const.Image.CHECK)
        } else {
            cell.checkIV.image = nil
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cell
    }
    
    /*
     セルをタップ
     */
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // タップしたセルを取得
        if let cell: OperationTableViewCell = versionTV.cellForRow(at: indexPath)
            as? OperationTableViewCell {
            // 選択状態を解除
            cell.isSelected = false
            // タップしたセルにチェックを表示
            cell.checkIV.image = UIImage(systemName: Const.Image.CHECK)
            versionNo = versions[indexPath.row].code
            versionTV.reloadData()
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     Doneボタン押下
     */
    @IBAction func tapDoneBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if versionNo != myUD.getVersion() {
            // 確認アラート表示
            let alert = UIAlertController(title: "", message: Const.Message.VERSION_CHANGE_COMFIRM
                , preferredStyle: UIAlertController.Style.alert)
            let okBtn = UIAlertAction(title: Const.Label.OK, style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) -> Void in

                let vc: MainViewController
                    = self.presentingViewController?.presentingViewController as! MainViewController
                
                // バージョンセット
                self.myUD.setVersion(no: self.versionNo)
                // データ取得処理
                let operation: Operation = Operation.init(mainVC: vc)
                let score: Results<MyScore> = operation.doOperation()
                // リスト画面リロード
                let listVC: ListViewController
                    = self.presentingViewController?.presentingViewController?.children[0] as! ListViewController
                listVC.scores = score
                listVC.listTV.reloadData()
                // メイン画面のUI処理
                vc.mainUI()
                // 閉じる
                self.dismiss(animated: false, completion: nil)
            })
            
            let cancelBtn = UIAlertAction(title: Const.Label.CANCEL, style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okBtn)
            alert.addAction(cancelBtn)
            self.present(alert, animated: false, completion: nil)
            
        } else {
            // 閉じる
            self.dismiss(animated: false, completion: nil)
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     Backボタン押下
     */
    @IBAction func tapBackBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
     右にスワイプ
     */
    @IBAction func swipeRight(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
}
