//
//  TargetAccountViewController.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class TargetAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var taTV: UITableView!
    @IBOutlet weak var noMissCountIV: UIImageView!
    @IBOutlet weak var yesMissCountIV: UIImageView!
    @IBOutlet weak var coverView: UIView!
    
    let myUD: MyUserDefaults = MyUserDefaults()
    var rivalStatuses: Results<RivalStatus>!
    var myStatus: Results<MyStatus>!
    var target: String = ""
    var missFlg: Bool = false
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        taTV.delegate = self
        taTV.dataSource = self
        
        let realm = CommonMethod.createScoreRealm()
        // マイステータスTBL取得
        myStatus = realm.objects(MyStatus.self)
        // ライバルステータスTBL取得
        rivalStatuses = realm.objects(RivalStatus.self)
            .filter("\(RivalStatus.Types.playStyle.rawValue) = %@", myUD.getPlayStyle())
        
        // 対象アカウント取得
        target = myUD.getTarget()
        
        // ミスカウントフラグ取得
        missFlg = myUD.getMissCountFlg()
        if missFlg {
            yesMissCountIV.image = UIImage(systemName: Const.Image.CHECK)
            noMissCountIV.image = nil
        } else {
            yesMissCountIV.image = nil
            noMissCountIV.image = UIImage(systemName: Const.Image.CHECK)
        }
        
        // カバーView
        if myUD.getTargetPage() == Const.Value.TargetPage.CSV {
            coverView.isHidden = false
        } else {
            coverView.isHidden = true
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     セルの数を返す
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return myStatus.count + rivalStatuses.count
    }
    
    /*
     セルを返す
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! TargetAccountTableViewCell
        
        var rowNo: Int = indexPath.row
        var iidxId: String = ""
        
        // 自分
        if rowNo == 0 {
            iidxId = myStatus.first?.iidxId ?? ""
            cell.iidxIdLbl.text = iidxId
            cell.iidxIdLbl.isHidden = true
            cell.djNameLbl.text = myStatus.first?.djName
            cell.rankLbl.text = myStatus.first?.rank
        // ライバル
        } else {
            rowNo -= 1
            iidxId = rivalStatuses[rowNo].iidxId ?? ""
            cell.iidxIdLbl.text = iidxId
            cell.iidxIdLbl.isHidden = true
            cell.djNameLbl.text = rivalStatuses[rowNo].djName
            cell.rankLbl.text = rivalStatuses[rowNo].rank
        }
        
        if target == iidxId {
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
        if let cell: TargetAccountTableViewCell = taTV.cellForRow(at: indexPath) as? TargetAccountTableViewCell {
            let iidxId: String = cell.iidxIdLbl.text ?? ""
            // 画像の切り替えと取込対象アカウントのセット
            target = iidxId
            cell.checkIV.image = UIImage(systemName: Const.Image.CHECK)
            taTV.reloadData()

            // 選択状態を解除
            cell.isSelected = false
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    /*
     ミスカウントなしボタン押下
     */
    @IBAction func tapNoMissCountBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)

        noMissCountIV.image = UIImage(systemName: Const.Image.CHECK)
        yesMissCountIV.image = nil
        missFlg = false
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     ミスカウントありボタン押下
     */
    @IBAction func tapYesMissCountBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        yesMissCountIV.image = UIImage(systemName: Const.Image.CHECK)
        noMissCountIV.image = nil
        missFlg = true
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     Doneボタン押下
     */
    @IBAction func tapDoneBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        myUD.setTarget(target: target)
        myUD.setMissCountFlg(flg: missFlg)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.presentingViewController?.presentingViewController?
            .dismiss(animated: false, completion: nil)
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
