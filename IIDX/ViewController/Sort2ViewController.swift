//
//  SortViewController.swift
//  IIDX
//
//  Created by umeme on 2019/09/01.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class Sort2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sortTV: UITableView!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var sortSegment: UISegmentedControl!
    
    var sorts: Results<Code>!
    let myUD: MyUserDefaults = MyUserDefaults()
    var ascOrDesc = 100
    var sort = 0
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        sortTV.delegate = self
        sortTV.dataSource = self

        let realm: Realm = CommonMethod.createSeedRealm()
        
        // ソート項目取得
        sorts = realm.objects(Code.self).filter("\(Code.Types.kindCode.rawValue) = %@", Const.Value.kindCode.SORT)
        
        // セグメント
        if (String(myUD.getSort()).hasPrefix("1")) {
            sortSegment.selectedSegmentIndex = 0
            ascOrDesc = 100
        } else {
            sortSegment.selectedSegmentIndex = 1
            ascOrDesc = 200
        }

        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    /*
     セルの数を返す
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return sorts.count
    }
    
    /*
     セルを返す
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! OperationTableViewCell
        
        // 項目名
        cell.itemLbl.text = sorts[indexPath.row].name

        // チェック
        if (ascOrDesc + sorts[indexPath.row].code) == myUD.getSort() {
            cell.checkIV.image = UIImage(systemName: Const.Image.CHECK)
            sort = sorts[indexPath.row].code
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
        if let cell: OperationTableViewCell = sortTV.cellForRow(at: indexPath)
            as? OperationTableViewCell {
            // 選択状態を解除
            cell.isSelected = false
            // タップしたセルにチェックを表示
            cell.checkIV.image = UIImage(systemName:  Const.Image.CHECK)
            sort = sorts[indexPath.row].code
            myUD.setSort(sort: ascOrDesc + sorts[indexPath.row].code)
            sortTV.reloadData()
            sortAndLoad()
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    /**
     セグメントをタップ
     */
    @IBAction func changeSegment(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            // 昇順
            ascOrDesc = 100
        case 1:
            // 降順
            ascOrDesc = 200
        default:
            print("該当なし")
        }
        myUD.setSort(sort: ascOrDesc + sort)
        sortAndLoad()
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     タッチイベント
     */
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

    /**
     ソート＆リロード
     */
    private func sortAndLoad() {
        // ソート処理
        let vc: MainViewController = self.presentingViewController as! MainViewController
        let operation: Operation = Operation.init(mainVC: vc)
        let sortedScore: Results<MyScore> = operation.doOperation()
        // リストTVリロード
        let listVC: ListViewController = self.presentingViewController?.children[0] as! ListViewController
        listVC.scores = sortedScore
        listVC.listTV.reloadData()
    }
}
