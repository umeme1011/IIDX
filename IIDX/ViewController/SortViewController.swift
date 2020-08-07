//
//  SortViewController.swift
//  IIDX
//
//  Created by umeme on 2019/09/01.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class SortViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sortTV: UITableView!
    @IBOutlet weak var sortView: UIView!
    
    var sorts: Results<Code>!
    let myUD: MyUserDefaults = MyUserDefaults()
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        sortTV.delegate = self
        sortTV.dataSource = self

        let realm: MyRealm = MyRealm.init(path: CommonMethod.getSeedRealmPath())
        
        // ソート項目取得
        sorts = realm.readEqual(Code.self, ofTypes: Code.Types.kindCode.rawValue
                , forQuery: [Const.Value.kindCode.SORT] as AnyObject)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    /// セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return sorts.count
    }
    
    /// セルを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! OperationTableViewCell
        
        // 項目名
        cell.itemLbl.text = sorts[indexPath.row].name

        // チェック
        if sorts[indexPath.row].code == myUD.getSort() {
            cell.checkIV.image = UIImage(named: Const.Image.CHECK)
        } else {
            cell.checkIV.image = nil
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cell
    }
    
    
    /// セルをタップ
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // タップしたセルを取得
        if let cell: OperationTableViewCell = sortTV.cellForRow(at: indexPath)
            as? OperationTableViewCell {
            // 選択状態を解除
            cell.isSelected = false
            // タップしたセルにチェックを表示
            cell.checkIV.image = UIImage(named: Const.Image.CHECK)
            myUD.setSort(sort: sorts[indexPath.row].code)
            sortTV.reloadData()
            
            // ソート処理
            let vc: MainViewController = self.presentingViewController as! MainViewController
            let operation: Operation = Operation.init(mainVC: vc)
            let sortedScore: Results<MyScore> = operation.doOperation()
            // リストTVリロード
            let listVC: ListViewController = self.presentingViewController?.children[0] as! ListViewController
            listVC.scores = sortedScore
            listVC.listTV.reloadData()
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }


    /// タッチイベント
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        super.touchesEnded(touches, with: event)
        for touch in touches {
            // メニューエリア以外をタップで閉じる
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.1,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.sortView.layer.position.x = +self.sortView.frame.width*2.5
                },
                    completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                }
                )
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}
