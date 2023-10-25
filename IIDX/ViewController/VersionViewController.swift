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
    @IBOutlet weak var tagCopyView: UIView!
    @IBOutlet weak var ghostCopyView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    var versions: Results<Code>!
    var myUD: MyUserDefaults = MyUserDefaults()
    var seedRealm: Realm!
    var versionNo: Int = 0
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        versionTV.delegate = self
        versionTV.dataSource = self
        
        indicatorView.isHidden = true
        indicator.hidesWhenStopped = true
        
//        seedRealm = CommonMethod.createSeedRealm()
        seedRealm = CommonMethod.createCurrentSeedRealm()
        
        // バージョン一覧取得
        versions = seedRealm.objects(Code.self)
            .filter("\(Code.Types.kindCode.rawValue) = %@ and \(Code.Types.code.rawValue) => %@", Const.Value.kindCode.VERSION, Const.Version.START_VERSION_NO)
            .sorted(byKeyPath: Code.Types.sort.rawValue)

        // バージョンNo取得
        versionNo = myUD.getVersion()
        
        // 現行バージョン　かつ　前作ゴーストのスコア取込がされている場合のみコピーボタンを活性にする
        let preScoreRealm = CommonMethod.createPreScoreRealm()
        if versionNo == Const.Version.CURRENT_VERSION_NO && !preScoreRealm.isEmpty {
            ghostCopyView.isHidden = true
        } else {
            ghostCopyView.isHidden = false
        }
        
//        // バージョン27の場合はタグ引き継ぎを非活性にする
//        if versionNo == Const.Version.START_VERSION_NO {
//            tagCopyView.isHidden = false
//        } else {
//            tagCopyView.isHidden = true
//        }
        
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
            
//            // バージョン27の場合はタグ引き継ぎを非活性にする
//            if versionNo == Const.Version.START_VERSION_NO {
//                tagCopyView.isHidden = false
//            } else {
//                tagCopyView.isHidden = true
//            }
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
                
                // バージョンセット
                self.myUD.setVersion(no: self.versionNo)
                // バージョン27を選択時は、前作ゴーストを非表示にする
                if self.versionNo == Const.Version.START_VERSION_NO {
                    self.myUD.setGhostDispFlg(flg: false)
                }
                // 初期処理
                let ini = Init.init()
                let alertMsg = ini.doInit()
                if alertMsg != "" {
                    if self.versionNo != Const.Version.START_VERSION_NO {
                        // タグ引き継ぎ
                        self.copyTag()
                    }
                    // データリロード
                    self.dataReload()
                    // 取り込み完了アラート表示
                    let alert = UIAlertController(title: "", message: alertMsg, preferredStyle: UIAlertController.Style.alert)
                    let okBtn = UIAlertAction(title: Const.Label.OK, style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
                        self.dismiss(animated: false, completion: nil)
                    })
                    alert.addAction(okBtn)
                    self.present(alert, animated: false, completion: nil)
                    
                } else {
                    // データリロード
                    self.dataReload()
                    // 閉じる
                    self.dismiss(animated: false, completion: nil)
                }
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
    
    /**
     タグデータ引き継ぎ（未使用）
     */
    @IBAction func tapCopy(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        copyTag()
        
        // アラート表示
        let alert = UIAlertController(title: "", message: "引き継ぎ完了！", preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: Const.Label.OK, style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
            self.dismiss(animated: false, completion: nil)
        })
        alert.addAction(okBtn)
        present(alert, animated: false, completion: nil)

        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     前作ゴーストコピー
     */
    @IBAction func tapGhostCopy(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // インジケータ表示
        indicatorView.isHidden = false
        indicator.startAnimating()

        let dispatchQueue: DispatchQueue = DispatchQueue(label: "ghost copy Thread")
        dispatchQueue.async() {
            Log.debugStart(cls: String(describing: self), method: #function + "Thread")

            // 前作ゴーストをコピー
            CommonMethod.copyGhostScore()
            
            // 前作タグをコピー
            CommonMethod.copyGhostTag()

            DispatchQueue.main.async {
                // インジケータ非表示
                self.indicatorView.isHidden = true
                self.indicator.stopAnimating()
                // アラート表示
                CommonMethod.dispAlert(message: "前作ゴーストをコピーしました。", vc: self)
            }
            Log.debugEnd(cls: String(describing: self), method: #function + "Thread")
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     タグコピー
     */
    private func copyTag() {
        let scoreRealm = CommonMethod.createScoreRealm()
        let preScoreRealm = CommonMethod.createPreScoreRealm()

        try! scoreRealm.write {
            
            let preTags = preScoreRealm.objects(Tag.self)
            let tags = scoreRealm.objects(Tag.self)
            
            // タグデータなし
            if preTags.isEmpty {
                return
            }
            
            // タグテーブル登録済みの場合は全件削除
            if !tags.isEmpty {
                scoreRealm.delete(tags)
            }
            // タグテーブル登録
            for tag in preTags {
                let t = Tag()
                t.id = tag.id
                t.tag = tag.tag
                scoreRealm.add(t)
            }
            
            let preScore = preScoreRealm.objects(MyScore.self).filter("\(MyScore.Types.tag.rawValue) != null")
            for score in preScore {
                if let s = scoreRealm.objects(MyScore.self)
                    .filter("\(MyScore.Types.title.rawValue) == %@", score.title!)
                    .filter("\(MyScore.Types.level.rawValue) == %@", score.level)
                    .filter("\(MyScore.Types.difficultyId.rawValue) == %@", score.difficultyId)
                    .filter("\(MyScore.Types.playStyle.rawValue) == %@", score.playStyle)
                    .first {
                    
                    // MyScoreテーブル更新
                    s.tag = score.tag
                }
            }
        }
    }
    
    /**
     データリロード処理
     */
    private func dataReload() {
        let vc: MainViewController
            = self.presentingViewController?.presentingViewController as! MainViewController

        // データ取得処理
        let operation: Operation = Operation.init(mainVC: vc)
        let score: Results<MyScore> = operation.doOperation()
        // リスト画面リロード
        let listVC: ListViewController
            = self.presentingViewController?.presentingViewController?.children[0] as! ListViewController
        // 前作スコア表示有無によるセルの高さ指定
        listVC.changeRowHeight()
        listVC.scores = score
        listVC.listTV.reloadData()
        // メイン画面のUI処理
        vc.mainUI()
        // 設定画面
        let parent = self.presentingViewController as! SettingViewController
        // バージョンラベルを変更
        parent.changeVersionLbl()
        // クプロ表示
        parent.dispQpro()
    }
}
