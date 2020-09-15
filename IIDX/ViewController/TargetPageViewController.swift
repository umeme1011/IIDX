//
//  TargetPageViewController.swift
//  IIDX
//
//  Created by umeme on 2020/09/03.
//  Copyright © 2020 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class TargetPageViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var levelIV: UIImageView!
    @IBOutlet weak var versionIV: UIImageView!
    @IBOutlet weak var csvIV: UIImageView!
    @IBOutlet weak var levelAllIV: UIImageView!
    @IBOutlet weak var versionAllIV: UIImageView!
    @IBOutlet weak var levelCV: UICollectionView!
    @IBOutlet weak var versionTV: UITableView!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var allView: UIView!
    @IBOutlet weak var noteLbl1: UILabel!
    @IBOutlet weak var noteLbl2: UILabel!
    
    let myUD: MyUserDefaults = MyUserDefaults()
    var seedRealm: Realm!
    
    var targetPage: Int = 0
    var levels: Results<Code>!
    var versions: Results<Code>!
    var levelCheckArray: [String] = [String]()
    var versionCheckArray: [String] = [String]()
    var levelAllFlg: Bool = false
    var versionAllFlg: Bool = false
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        levelCV.delegate = self
        levelCV.dataSource = self
        versionTV.delegate = self
        versionTV.dataSource = self

        let realm: Realm = CommonMethod.createSeedRealm()
        
        // レベル項目取得
        levels = realm.objects(Code.self)
            .filter("\(Code.Types.kindCode.rawValue) = %@", Const.Value.kindCode.LEVEL)
            .sorted(byKeyPath: Code.Types.sort.rawValue)
        
        // バージョン項目取得
        versions = realm.objects(Code.self)
            .filter("\(Code.Types.kindCode.rawValue) = %@", Const.Value.kindCode.VERSION)
            .sorted(byKeyPath: Code.Types.sort.rawValue)

        // CVにレイアウトを設定
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0  // 横間隔
        layout.minimumLineSpacing = 0       // 縦間隔
//        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        levelCV.collectionViewLayout = layout
        
        // UserDefaults保持データ取得
        targetPage = myUD.getTargetPage()
        levelCheckArray = myUD.getTargetPageLevelCheckArray()
        versionCheckArray = myUD.getTargetPageVersionCheckArray()
        levelAllFlg = myUD.getTargetPageLevelAllFlg()
        versionAllFlg = myUD.getTargetPageVersionAllFlg()
        
        // ALlチェック表示
        if levelAllFlg {
            levelAllIV.image = UIImage(named: Const.Image.CHECK)
        }
        if versionAllFlg {
            versionAllIV.image = UIImage(named: Const.Image.CHECK)
        }
        
        // 取り込み先表示切り替え
        switchDisp()

        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     難易度ボタンタップ
     */
    @IBAction func tapDifficultyBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        targetPage = Const.Value.TargetPage.LEVEL
        // 表示切り替え
        switchDisp()
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     シリーズボタンタップ
     */
    @IBAction func tapSeriesBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        targetPage = Const.Value.TargetPage.VERSION
        // 表示切り替え
        switchDisp()
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     CSVボタンタップ
     */
    @IBAction func tapCsvBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        targetPage = Const.Value.TargetPage.CSV
        // 表示切り替え
        switchDisp()
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     Doneボタンタップ
     */
    @IBAction func tapDoneBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // UserDefaultsにデータ保持
        myUD.setTargetPage(target: targetPage)
        myUD.setTargetPageLevelCheckArray(array: levelCheckArray)
        myUD.setTargetPageVersionCheckArray(array: versionCheckArray)
        myUD.setTargetPageLevelAllFlg(flg: levelAllFlg)
        myUD.setTargetPageVersionAllFlg(flg: versionAllFlg)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.presentingViewController?.presentingViewController?
            .dismiss(animated: false, completion: nil)
    }
    
    /*
     Allボタンタップ
     */
    @IBAction func tapAllBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        switch targetPage {
            // 難易度選択時
            case Const.Value.TargetPage.LEVEL:
                if levelAllFlg {
                    levelAllFlg = false
                    levelAllIV.image = nil
                    levelCheckArray.removeAll()
                } else {
                    levelAllFlg = true
                    levelAllIV.image = UIImage(named: Const.Image.CHECK)
                    for level in levels {
                        if !levelCheckArray.contains(String(level.code)) {
                            levelCheckArray.append(String(level.code))
                        }
                    }
                }
                levelCV.reloadData()
            // シリーズ選択時
            case Const.Value.TargetPage.VERSION:
                if versionAllFlg {
                    versionAllFlg = false
                    versionAllIV.image = nil
                    versionCheckArray.removeAll()
                } else {
                    versionAllFlg = true
                    versionAllIV.image = UIImage(named: Const.Image.CHECK)
                    for version in versions {
                        if !versionCheckArray.contains(String(version.code)) {
                            versionCheckArray.append(String(version.code))
                        }
                    }
                }
                versionTV.reloadData()
                
            default:
                print("処理なし")
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     Backボタンタップ
     */
    @IBAction func tapBackBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
     表示切り替え
     */
    private func switchDisp() {
        switch targetPage {
            // 難易度選択時
            case Const.Value.TargetPage.LEVEL:
                versionTV.isHidden = true
                versionIV.image = nil
                versionAllIV.isHidden = true
                levelCV.isHidden = false
                levelIV.image = UIImage(named: Const.Image.CHECK)
                levelAllIV.isHidden = false
                allView.isHidden = false
                csvIV.image = nil
                noteLbl1.isHidden = false
                noteLbl2.isHidden = true
            // シリーズ選択時
            case Const.Value.TargetPage.VERSION:
                versionTV.isHidden = false
                versionIV.image = UIImage(named: Const.Image.CHECK)
                versionAllIV.isHidden = false
                levelCV.isHidden = true
                levelIV.image = nil
                levelAllIV.isHidden = true
                allView.isHidden = false
                csvIV.image = nil
                noteLbl1.isHidden = false
                noteLbl2.isHidden = true
            // CSV選択時
            case Const.Value.TargetPage.CSV:
                versionTV.isHidden = true
                versionIV.image = nil
                levelCV.isHidden = true
                levelIV.image = nil
                allView.isHidden = true
                csvIV.image = UIImage(named: Const.Image.CHECK)
                noteLbl1.isHidden = true
                noteLbl2.isHidden = false
            default:
                print("処理なし")
        }
    }
}

/*
 バージョン選択用TavleView
 */
extension TargetPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return versions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:indexPath as IndexPath)
            as! TargetPageTableViewCell
        
        // コード
        cell.codeLbl.text = String(versions[indexPath.row].code)
        // 項目名
        cell.versionLbl.text = versions[indexPath.row].name

        // チェック
        if versionCheckArray.isEmpty {
            cell.checkIV.image = nil
        } else {
            for ver in versionCheckArray {
                if ver == cell.codeLbl.text {
                    cell.checkIV.image = UIImage(named: Const.Image.CHECK)
                    break
                } else {
                    cell.checkIV.image = nil
                }
            }
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
        if let cell: TargetPageTableViewCell = versionTV.cellForRow(at: indexPath) as? TargetPageTableViewCell {
            
            // 選択状態を解除
            cell.isSelected = false
            
            // チェック切り替え
            let code: String = cell.codeLbl.text ?? ""
            if versionCheckArray.contains(code) {
                versionCheckArray.remove(value: code)
            } else {
                versionCheckArray.append(code)
            }

            versionTV.reloadData()
            
            // 全選択かどうか
//            print(versionCheckArray)
//            print(versions)
            if versionCheckArray.count == versions.count {
                versionAllFlg = true
                versionAllIV.image = UIImage(named: Const.Image.CHECK)
            } else {
                versionAllFlg = false
                versionAllIV.image = nil
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}

/*
 レベル選択用CollectionView
 */
extension TargetPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return levels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for:indexPath as IndexPath)
            as! TargetPageCollectionViewCell
        
        // コード
        cell.codeLbl.text = String(levels[indexPath.row].code)
        // 項目名
        cell.levelLbl.text = levels[indexPath.row].name

        // チェック
        if levelCheckArray.isEmpty {
            cell.checkIV.image = nil
        } else {
            for ver in levelCheckArray {
                if ver == cell.codeLbl.text {
                    cell.checkIV.image = UIImage(named: Const.Image.CHECK)
                    break
                } else {
                    cell.checkIV.image = nil
                }
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cell
    }
    
    /*
     セルサイズ
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        Log.debugStart(cls: String(describing: self), method: #function)
        let cellSize : CGFloat = self.view.bounds.width / 2
        Log.debugEnd(cls: String(describing: self), method: #function)
        return CGSize(width: cellSize, height: 35)
    }

    /*
     セルをタップ
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Log.debugStart(cls: String(describing: self), method: #function)

        // タップしたセルを取得
        if let cell: TargetPageCollectionViewCell = levelCV.cellForItem(at: indexPath) as? TargetPageCollectionViewCell {
            
            // 選択状態を解除
            cell.isSelected = false
            
            // チェック切り替え
            let code: String = cell.codeLbl.text ?? ""
            if levelCheckArray.contains(code) {
                levelCheckArray.remove(value: code)
            } else {
                levelCheckArray.append(code)
            }

            levelCV.reloadData()
            
            // 全選択かどうか
            if levelCheckArray.count == levels.count {
                levelAllFlg = true
                levelAllIV.image = UIImage(named: Const.Image.CHECK)
            } else {
                levelAllFlg = false
                levelAllIV.image = nil
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}
