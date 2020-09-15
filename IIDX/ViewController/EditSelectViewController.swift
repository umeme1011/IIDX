//
//  EditSelectViewController.swift
//  IIDX
//
//  Created by umeme on 2019/10/13.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class EditSelectViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var editSelectView: UIView!
    @IBOutlet weak var editSelectTV: UITableView!
    @IBOutlet weak var checkBtn: UIButton!
    
    var editScoreArray: [MyScore] = [MyScore]()
    var scores: Results<MyScore>!
    
    var seedRealm: MyRealm!
    var scoreRealm: MyRealm!
    let myUD: MyUserDefaults = MyUserDefaults()
    var clearLumps: Results<Code>!
    var djLevels: Results<Code>!
    var tags: Results<Tag>!
    var foldingFlgArray: [Bool] = [Bool]()
    var checkArray: [Int] = [Int]()
    var titleArray: [String] = [String]()
    
    let CLEAR_LUMP: Int = 0
    let DJ_LEVEL: Int = 1
    let TAG: Int = 2
    let ITEM_CNT = 3
    let NO_CHECK = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editSelectTV.delegate = self
        editSelectTV.dataSource = self
        
        seedRealm = MyRealm.init(path: CommonMethod.getSeedRealmPath())
        scoreRealm = MyRealm.init(path: CommonMethod.getScoreRealmPath())

        // 項目作成
        clearLumps = seedRealm.readEqual(Code.self, ofTypes: Code.Types.kindCode.rawValue
            , forQuery: [Const.Value.kindCode.CLEAR_LUMP] as AnyObject).sorted(byKeyPath: Code.Types.sort.rawValue)
        djLevels = seedRealm.readEqual(Code.self, ofTypes: Code.Types.kindCode.rawValue
            , forQuery: [Const.Value.kindCode.DJ_LEVEL] as AnyObject).sorted(byKeyPath: Code.Types.sort.rawValue)
        tags = scoreRealm.readAll(Tag.self)
        
        // アコーディオン用Array
        foldingFlgArray = [Bool](repeating: false, count: ITEM_CNT)
        // チェック用Array
        checkArray = [Int](repeating: NO_CHECK, count: ITEM_CNT)
    }
    
    
    /// セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cnt: Int = 0
        if foldingFlgArray[section] {
            switch section {
            case CLEAR_LUMP:
                cnt = clearLumps.count
            case DJ_LEVEL:
                cnt = djLevels.count
            case TAG:
                cnt = tags.count
            default:
                cnt = 0
            }
        }
        return cnt
    }
    
    
    /// セルを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! OperationTableViewCell
        
        cell.checkIV.image = nil

        var item: String = ""
        var code: String = ""
        switch indexPath.section {
        case CLEAR_LUMP:
            item = clearLumps[indexPath.row].name ?? ""
            code = String(clearLumps[indexPath.row].code)
        case DJ_LEVEL:
            item = djLevels[indexPath.row].name ?? ""
            code = String(djLevels[indexPath.row].code)
        case TAG:
            item = tags[indexPath.row].tag ?? ""
            code = String(tags[indexPath.row].id)
        default:
            item = ""
            code = ""
        }
        cell.itemLbl.text = item
        cell.codeLbl.text = code
        
        // check
        for i in 0..<checkArray.count {
            let section = i
            let row = checkArray[i]
            if section == indexPath.section && row == indexPath.row {
                cell.checkIV.image = UIImage(named: Const.Image.CHECK)
                break
            } else {
                cell.checkIV.image = nil
            }
        }

        return cell
    }
    
    
    /// セルをタップ
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        // タップしたセルを取得
        if let cell: OperationTableViewCell = editSelectTV.cellForRow(at: indexPath)
            as? OperationTableViewCell {
            // 選択状態を解除
            cell.isSelected = false
            // タップしたセルにチェックを表示
            if cell.checkIV.image == nil {
                cell.checkIV.image = UIImage(named: Const.Image.CHECK)
                checkArray[indexPath.section] = indexPath.row
            } else {
                cell.checkIV.image = nil
                checkArray[indexPath.section] = NO_CHECK
            }
            editSelectTV.reloadData()
        }
    }

    
    /// セクションの数を返す
    func numberOfSections(in tableView: UITableView) -> Int {
        return ITEM_CNT
    }

    
    /// セクションのUIViewを返す
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView()
        let label: UILabel = UILabel()
        
        var title: String = ""
        switch section {
        case CLEAR_LUMP:
            title = clearLumps.first?.kindName ?? ""
        case DJ_LEVEL:
            title = djLevels.first?.kindName ?? ""
        case TAG:
            title = "TAG"
        default:
            title = ""
        }
        label.text = title
        
        // Viewデザイン
        let screenWidth:CGFloat = editSelectView.frame.size.width
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 0.5
        view.frame = CGRect(x:0, y:0, width:screenWidth, height:35)
        view.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        // labelデザイン
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 15)
        label.frame = CGRect(x:10, y:0, width:screenWidth-10, height:35)
        label.textColor = UIColor.darkGray
        
        view.addSubview(label)
        
        // セクションのビューに対応する番号を設定する
        view.tag = section
        
        // セクションのビューにタップジェスチャーを設定する
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapHeader(gestureRecognizer:))))
        return view
    }
    
    
    /// セクションの高さを返す
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    
    /// セクションをタップ
    @objc func tapHeader(gestureRecognizer: UITapGestureRecognizer) {
        // タップされたセクションを取得
        guard let section = gestureRecognizer.view?.tag else {
            return
        }
        if foldingFlgArray[section] {
            foldingFlgArray[section] = false
        } else {
            foldingFlgArray[section] = true
        }
        editSelectTV.reloadData()
        
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
                        self.editSelectView.layer.position.x = +self.editSelectView.frame.width*2.5
                    },
                    completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                    }
                )
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    
    @IBAction func tapCancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapDoneBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapCheckAllBtn(_ sender: Any) {
        if checkBtn.backgroundImage(for: .normal) == nil {
            checkBtn.setBackgroundImage(UIImage(named: Const.Image.CHECK), for: .normal)
            editScoreArray = Array(scores)
        } else {
            checkBtn.setBackgroundImage(nil, for: .normal)
            editScoreArray.removeAll()
        }
        
        // リストTVリロード
        let listVC: ListViewController = self.presentingViewController?.children[0] as! ListViewController
        listVC.editScoreArray = editScoreArray
        listVC.listTV.reloadData()
    }
}
