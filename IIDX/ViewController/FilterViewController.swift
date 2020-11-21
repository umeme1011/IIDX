//
//  FilterViewController.swift
//  IIDX
//
//  Created by umeme on 2019/09/02.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class FilterViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterTV: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var seedRealm: Realm!
    var scoreRealm: Realm!
    let myUD: MyUserDefaults = MyUserDefaults()
    var filters: Results<Code>!
    var filterArray: [Results<Code>] = [Results<Code>]()
    var rivalFilters: Results<Code>!
    var rivalFilterArray: [Results<RivalStatus>] = [Results<RivalStatus>]()
    var tagFilters: Results<Tag>!
    var foldingFlgArray: [Bool] = [Bool]()
    var rivalFoldingFlgArray: [Bool] = [Bool]()
    var tagFoldingFlg: Bool!
    var checkDic: Dictionary = Dictionary<String, [Int]>()
    var rivalCheckDic: Dictionary = Dictionary<Int, [String]>()
    var tagCheckArray: [String] = [String]()
    var titleArray: [String] = [String]()
    var ghostFilters = [String]()
    var ghostFoldingFlg: Bool!
    var ghostCheckArray: [String] = [String]()

    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        filterTV.delegate = self
        filterTV.dataSource = self
        searchBar.delegate = self
        
        seedRealm = CommonMethod.createSeedRealm()
        scoreRealm = CommonMethod.createScoreRealm()
        
        // TODO
        // 検索バーの色変更
        var tf: UITextField!
        if #available(iOS 13.0, *) {
            searchBar.backgroundImage = UIImage()
            tf = searchBar.searchTextField
        } else {
            let iv = searchBar.value(forKey: "_background") as! UIImageView
            iv.removeFromSuperview()
            searchBar.backgroundColor = UIColor.white
            tf = searchBar.value(forKey: "_searchField") as? UITextField
        }
        tf.backgroundColor = UIColor.groupTableViewBackground
        tf.textColor = UIColor.darkGray
        
        // 項目作成
        filters = seedRealm.objects(Code.self)
            .filter("\(Code.Types.kindCode.rawValue) = %@", Const.Value.kindCode.FILTER)
        makeFilterArray(kindCode: Const.Value.kindCode.NEW_RECORD)
        makeFilterArray(kindCode: Const.Value.kindCode.LEVEL)
        makeFilterArray(kindCode: Const.Value.kindCode.DIFFICULTY)
        makeFilterArray(kindCode: Const.Value.kindCode.VERSION)
        makeFilterArray(kindCode: Const.Value.kindCode.CLEAR_LUMP)
        makeFilterArray(kindCode: Const.Value.kindCode.DJ_LEVEL)
        makeFilterArray(kindCode: Const.Value.kindCode.INDEX)
        // 項目作成（ライバル）
        rivalFilters = seedRealm.objects(Code.self)
            .filter("\(Code.Types.kindCode.rawValue) = %@", Const.Value.kindCode.RIVAL_FILTER)
        makeRivalFilterArray(kindCode: Const.Value.kindCode.RIVAL_SCORE_LOSE)
        makeRivalFilterArray(kindCode: Const.Value.kindCode.RIVAL_SCORE_WIN)
        makeRivalFilterArray(kindCode: Const.Value.kindCode.RIVAL_LUMP_LOSE)
        makeRivalFilterArray(kindCode: Const.Value.kindCode.RIVAL_LUMP_WIN)
        // 項目作成（タグ）
        tagFilters = scoreRealm.objects(Tag.self)
        // 項目作成（前作ゴースト）
        if myUD.getGhostDispFlg() {
            ghostFilters = ["WIN", "LOSE"]
        }
        
        // 折りたたみフラグ
        foldingFlgArray = myUD.getFoldingFlgArray()
        // 折りたたみフラグ（ライバル）
        rivalFoldingFlgArray = myUD.getRivalFoldingFlgArray()
        // 折りたたみフラグ（タグ）
        tagFoldingFlg = myUD.getTagFoldingFlg()
        // 折りたたみフラグ（前作ゴースト）
        ghostFoldingFlg = myUD.getGhostFoldingFlg()
        
        // チェックリスト
        var data: Data = myUD.getCheckDic()
        checkDic = NSKeyedUnarchiver.unarchiveObject(with: data)
            as? Dictionary<String, [Int]> ?? Dictionary<String, [Int]>()
        data = myUD.getRivalCheckDic()
        rivalCheckDic = NSKeyedUnarchiver.unarchiveObject(with: data)
            as? Dictionary<Int, [String]> ?? Dictionary<Int, [String]>()
        tagCheckArray = myUD.getTagCheckArray()
        ghostCheckArray = myUD.getGhostCheckArray()
        
        // タイトル
        titleArray = myUD.getTitleArray()
        
        // 検索バー
        searchBar.text = myUD.getSearchWord()
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     セルの数を返す
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        var cnt: Int = 0
        if section < filters.count {
            if foldingFlgArray[section] {
                cnt = filterArray[section].count
            }
        } else if (section < (filters.count + rivalFilters.count)) && !rivalFilterArray.isEmpty {
            let i = section - filters.count
            if rivalFoldingFlgArray[i] {
                cnt = rivalFilterArray[i].count
            }
        } else if !tagFilters.isEmpty {
            if tagFoldingFlg {
                cnt = tagFilters.count
            }
        } else if !ghostFilters.isEmpty {
            if ghostFoldingFlg {
                cnt = ghostFilters.count
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cnt
    }
    
    /*
     セルを返す
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! OperationTableViewCell
        
         // 通常フィルター
        if indexPath.section < filters.count {
            // 項目名
            // コード（非表示）
            let codes: Results<Code> = filterArray[indexPath.section]
            if codes[indexPath.row].kindCode == Const.Value.kindCode.NEW_RECORD {
                // NEW RECORDの場合最終取込日を表示
                if let lastImportDate: LastImportDate = scoreRealm.objects(LastImportDate.self)
                    .filter("\(LastImportDate.Types.playStyle.rawValue) = %@", myUD.getPlayStyle()).first {
                    cell.itemLbl.text = lastImportDate.date
                    cell.codeLbl.text = String(lastImportDate.id)
                } else {
                    cell.itemLbl.text = "none"
                }
                
            } else {
                cell.itemLbl.text = codes[indexPath.row].name
                cell.codeLbl.text = String(codes[indexPath.row].code)
            }
            // チェック
            let key: String = convertSectionToColumn(section: indexPath.section)
            if checkDic.isEmpty || checkDic[key] == nil {
                cell.checkIV.image = nil
            } else {
                let code: Int = Int(cell.codeLbl.text ?? "") ?? 0
                for check in checkDic[key]! {
                    if check == code {
                        cell.checkIV.image = UIImage(systemName: Const.Image.CHECK)
                        break
                    } else {
                        cell.checkIV.image = nil
                    }
                }
            }
            
        // ライバルフィルター
        } else if (indexPath.section < (filters.count + rivalFilters.count)) && !rivalFilterArray.isEmpty {
            // 項目名
            // コード（非表示）
            let i = indexPath.section - filters.count
            let rivalStatuses: Results<RivalStatus> = rivalFilterArray[i]
            if !rivalStatuses.isEmpty {
                cell.itemLbl.text = rivalStatuses[indexPath.row].djName
                cell.codeLbl.text = rivalStatuses[indexPath.row].iidxId
            } else {
                cell.itemLbl.text = "No rivals"
                cell.selectionStyle = .none     // 選択不可にする
            }
            // チェック
            let key: Int = i
            if rivalCheckDic.isEmpty || rivalCheckDic[key] == nil {
                cell.checkIV.image = nil
            } else {
                let code: String = cell.codeLbl.text ?? ""      // code = iidxId
                for check in rivalCheckDic[key]! {
                    if check == code {
                        cell.checkIV.image = UIImage(systemName: Const.Image.CHECK)
                        break
                    } else {
                        cell.checkIV.image = nil
                    }
                }
            }
        
        // タグフィルター
        } else if !tagFilters.isEmpty {
            // 項目名
            cell.itemLbl.text = tagFilters[indexPath.row].tag
            // コード（未使用）
            cell.codeLbl.text = String(tagFilters[indexPath.row].id)
            // チェック
            if tagCheckArray.isEmpty {
                cell.checkIV.image = nil
            } else {
                for tag in tagCheckArray {
                    if tag == cell.itemLbl.text {
                        cell.checkIV.image = UIImage(systemName: Const.Image.CHECK)
                        break
                    } else {
                        cell.checkIV.image = nil
                    }
                }
            }
            
        // 前作ゴーストフィルター
        } else if !ghostFilters.isEmpty {
            // 項目名
            cell.itemLbl.text = ghostFilters[indexPath.row]
            // チェック
            if ghostCheckArray.isEmpty {
                cell.checkIV.image = nil
            } else {
                for tag in ghostCheckArray {
                    if tag == cell.itemLbl.text {
                        cell.checkIV.image = UIImage(systemName: Const.Image.CHECK)
                        break
                    } else {
                        cell.checkIV.image = nil
                    }
                }
            }
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cell
    }
    
    /*
     セクションの数を返す
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        var cnt: Int = filters.count
        // ライバル不在の場合はライバル項目を表示しない
        if !rivalFilterArray.isEmpty {
            cnt += rivalFilters.count
        }
        // タグ未登録の場合はタグ項目を表示しない
        if !tagFilters.isEmpty {
            cnt += 1
        }
        // 前作ゴーストを表示しない設定の場合は前作ゴースト項目を表示しない
        if !ghostFilters.isEmpty {
            cnt += 1
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cnt
    }

    /*
     セクションのUIViewを返す
     */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        Log.debugStart(cls: String(describing: self), method: #function)
        let view: UIView = UIView()
        let label: UILabel = UILabel()
        
        if section < filters.count {
            label.text = filters[section].name
        } else if (section < (filters.count + rivalFilters.count)) && !rivalFilterArray.isEmpty {
            let i = section - filters.count
            label.text = rivalFilters[i].name
        } else if !tagFilters.isEmpty {
            label.text = "TAG"
        } else if !ghostFilters.isEmpty {
            label.text = "GHOST SCORE"
        }
        
        // Viewデザイン
        let screenWidth:CGFloat = filterView.frame.size.width
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
        
        //        // セクションのビューにロングタップジェスチャーを設定する
        //        myView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.longTapHeader(gestureRecognizer:))))
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return view
    }
    
    /*
     セクションの高さを返す
     */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return 35
    }

    /*
     セクションをタップ
     */
    @objc func tapHeader(gestureRecognizer: UITapGestureRecognizer) {
        Log.debugStart(cls: String(describing: self), method: #function)
        // タップされたセクションを取得
        guard let section = gestureRecognizer.view?.tag else {
            return
        }
        
        // 通常フィルター
        if section < filters.count {
            if foldingFlgArray[section] {
                foldingFlgArray[section] = false
            } else {
                foldingFlgArray[section] = true
            }
            myUD.setFoldingFlgArray(array: foldingFlgArray)
            
        // ライバルフィルター
        } else if (section < (filters.count + rivalFilters.count)) && !rivalFilterArray.isEmpty {
            let i = section - filters.count
            if rivalFoldingFlgArray[i] {
                rivalFoldingFlgArray[i] = false
            } else {
                rivalFoldingFlgArray[i] = true
            }
            myUD.setRivalFoldingFlgArray(array: rivalFoldingFlgArray)
        
        // タグフィルター
        } else if !tagFilters.isEmpty {
            if tagFoldingFlg {
                tagFoldingFlg = false
            } else {
                tagFoldingFlg = true
            }
            myUD.setTagFoldingFlg(flg: tagFoldingFlg)
            
        // 前作ゴーストフィルター
        } else if !ghostFilters.isEmpty {
            if ghostFoldingFlg {
                ghostFoldingFlg = false
            } else {
                ghostFoldingFlg = true
            }
            myUD.setGhostFoldingFlg(flg: ghostFoldingFlg)
        }
        
        filterTV.reloadData()
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     セルをタップ
     */
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        Log.debugStart(cls: String(describing: self), method: #function)
        // タップしたセルを取得
        if let cell: OperationTableViewCell = filterTV.cellForRow(at: indexPath)
            as? OperationTableViewCell {
            
            // 選択状態を解除
            cell.isSelected = false
            
            let item: String = cell.itemLbl.text ?? ""

            // 通常フィルター項目
            if indexPath.section < filters.count {
                // チェック切り替え
                let key: String = convertSectionToColumn(section: indexPath.section)
                if cell.checkIV.image == UIImage(systemName: Const.Image.CHECK) {
                    checkDic[key]?.remove(value: Int(cell.codeLbl.text ?? "") ?? 0)
                    if checkDic[key]?.count == 0 {
                        checkDic.removeValue(forKey: key)
                    }
                    titleArray.remove(value: item)
                } else {
                    var checkArray: [Int] = checkDic[key] ?? [Int]()
                    checkArray.append(Int(cell.codeLbl.text ?? "") ?? 0)
                    checkDic[key] = checkArray
                    titleArray.append(item)
                }
                
            // ライバルファイルター項目
            } else if (indexPath.section < (filters.count + rivalFilters.count)) && !rivalFilterArray.isEmpty {
                let key: Int = indexPath.section - filters.count
                // タイトル用文字列作成
                let filterName: String = rivalFilters[key].name ?? ""
                var title: String = ""
                if let range = filterName.range(of: "RIVAL") {
                    title = filterName.replacingCharacters(in: range, with: item)
                }
                // チェック切り替え
                if cell.checkIV.image == UIImage(systemName: Const.Image.CHECK) {
                    rivalCheckDic[key]?.remove(value: cell.codeLbl.text ?? "")
                    if rivalCheckDic[key]?.count == 0 {
                        rivalCheckDic.removeValue(forKey: key)
                    }
                    titleArray.remove(value: title)
                } else {
                    var checkArray: [String] = rivalCheckDic[key] ?? [String]()
                    checkArray.append(cell.codeLbl.text ?? "")
                    rivalCheckDic[key] = checkArray
                    titleArray.append(title)
                }
            
            // タグフィルター項目
            } else if !tagFilters.isEmpty {
                // チェック切り替え
                if cell.checkIV.image == UIImage(systemName: Const.Image.CHECK) {
                    tagCheckArray.remove(value: item)
                    titleArray.remove(value: item)
                } else {
                    tagCheckArray.append(item)
                    titleArray.append(item)
                }
            
            // 前作ゴーストフィルター項目
            } else if !ghostFilters.isEmpty {
                // チェック切り替え
                if cell.checkIV.image == UIImage(systemName: Const.Image.CHECK) {
                    ghostCheckArray.remove(value: item)
                    titleArray.remove(value: "GHOST SCORE " + item)
                } else {
                    ghostCheckArray.append(item)
                    titleArray.append("GHOST SCORE " + item)
                }
            }

            filterTV.reloadData()
            
            // フィルター処理
            filter()
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     検索バーテキスト変更時
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Log.debugStart(cls: String(describing: self), method: #function)
        // フィルター処理
        filter()
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     キーボードの検索ボタン押下時
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Log.debugStart(cls: String(describing: self), method: #function)
        // キーボードを閉じる
        searchBar.endEditing(true)
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    /*
     AllClearボタン押下時
     */
    @IBAction func tapAllClearBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
       // いろいろ初期化
        searchBar.text = ""
        foldingFlgArray = [false,false,false,false,false,false,false]
        checkDic = Dictionary<String, [Int]>()
        rivalFoldingFlgArray = [false,false,false,false]
        rivalCheckDic = Dictionary<Int, [String]>()
        tagFoldingFlg = false
        tagCheckArray = [String]()
        ghostFoldingFlg = false
        ghostCheckArray = [String]()
        filterTV.reloadData()
        
        // 折りたたみフラグ
        myUD.setFoldingFlgArray(array: foldingFlgArray)
        myUD.setRivalFoldingFlgArray(array: rivalFoldingFlgArray)
        myUD.setTagFoldingFlg(flg: false)
        myUD.setGhostFoldingFlg(flg: false)
        
        // タイトル初期化
        titleArray.removeAll()
        myUD.setTitleArray(title: titleArray)
        
        // フィルター処理
        filter()
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
                        self.filterView.layer.position.x = +self.filterView.frame.width*2.5
                },
                    completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                }
                )
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
   }
    
    /*
     各フィルター項目配列作成
     */
    private func makeFilterArray(kindCode: Int) {
        Log.debugStart(cls: String(describing: self), method: #function)
        var codes: Results<Code> = seedRealm.objects(Code.self)
            .filter("\(Code.Types.kindCode.rawValue) = %@", kindCode)
        codes = codes.sorted(byKeyPath: Code.Types.sort.rawValue)
        filterArray.append(codes)
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     各フィルター項目配列作成（ライバル）
     */
    private func makeRivalFilterArray(kindCode: Int) {
        Log.debugStart(cls: String(describing: self), method: #function)
        // ライバルリスト取得
        let result: Results<RivalStatus> = scoreRealm.objects(RivalStatus.self)
            .filter("\(RivalStatus.Types.playStyle.rawValue) = %@", myUD.getPlayStyle())
        if !result.isEmpty {
            rivalFilterArray.append(result)
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    /*
     セクションNoをMyScoreテーブルのカラム名に変換する
     */
    private func convertSectionToColumn(section: Int) -> String {
        Log.debugStart(cls: String(describing: self), method: #function)
        var key: String = ""
        switch section {
        case Const.Value.Filter.NEW_RECORD:
            key = MyScore.Types.lastImportDateId.rawValue
        case Const.Value.Filter.LEVEL:
            key = MyScore.Types.level.rawValue
        case Const.Value.Filter.DIFFICULTY:
            key = MyScore.Types.difficultyId.rawValue
        case Const.Value.Filter.VERSION:
            key = MyScore.Types.versionId.rawValue
        case Const.Value.Filter.CLEAR_LUMP:
            key = MyScore.Types.clearLump.rawValue
        case Const.Value.Filter.DJ_LEVEL:
            key = MyScore.Types.djLevel.rawValue
        case Const.Value.Filter.INDEX:
            key = MyScore.Types.indexId.rawValue
        default:
            return key
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return key
    }
    
    /*
     フィルター処理
     */
    private func filter() {
        Log.debugStart(cls: String(describing: self), method: #function)
        // UserDefaultsに検索ワード、絞り込み条件をセット
        myUD.setSearchWord(word: searchBar.text ?? "")
        var data: Data = NSKeyedArchiver.archivedData(withRootObject: checkDic)
        myUD.setCheckDic(dic: data)
        data = NSKeyedArchiver.archivedData(withRootObject: rivalCheckDic)
        myUD.setRivalCheckDic(dic: data)
        myUD.setTagCheckArray(array: tagCheckArray)
        myUD.setGhostCheckArray(array: ghostCheckArray)
        
        // タイトル
        myUD.setTitleArray(title: titleArray)
        
        // フィルター処理
        let vc: MainViewController = self.presentingViewController as! MainViewController
        let operation: Operation = Operation.init(mainVC: vc)
        let filteredScore: Results<MyScore> = operation.doOperation()

        // リストTVリロード
        let listVC: ListViewController = self.presentingViewController?.children[0] as! ListViewController
        listVC.scores = filteredScore
        listVC.listTV.reloadData()
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}
