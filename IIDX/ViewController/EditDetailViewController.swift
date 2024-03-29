//
//  EditDetailViewController.swift
//  IIDX
//
//  Created by umeme on 2019/10/10.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class EditDetailViewController: UIViewController, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var difficultyLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    
    @IBOutlet weak var clearLumpTF: UITextField!
    @IBOutlet weak var djLevelTF: UITextField!
    @IBOutlet weak var scoreTF: UITextField!
    @IBOutlet weak var missCountTF: UITextField!
    @IBOutlet weak var tagTF: UITextField!
    @IBOutlet weak var tagCV: UICollectionView!
    
    var score: MyScore!
    var clearLumpPV: UIPickerView = UIPickerView()
    var djLevelPV: UIPickerView = UIPickerView()
    var tagPV: UIPickerView = UIPickerView()
    var seedRealm: MyRealm!
    var scoreRealm: MyRealm!
    var clearLumps: Results<Code>!
    var djLevels: Results<Code>!
    var tags: Results<Tag>!
    var tagArray: [String] = [String]()
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        self.tagCV.delegate = self
        self.tagCV.dataSource = self
        self.clearLumpPV.delegate = self
        self.clearLumpPV.dataSource = self
        self.clearLumpPV.showsSelectionIndicator = true
        self.djLevelPV.delegate = self
        self.djLevelPV.dataSource = self
        self.djLevelPV.showsSelectionIndicator = true
        self.tagPV.delegate = self
        self.tagPV.dataSource = self
        self.tagPV.showsSelectionIndicator = true

        seedRealm = MyRealm.init(path: CommonMethod.getSeedRealmPath())
        scoreRealm = MyRealm.init(path: CommonMethod.getScoreRealmPath())
        
        // バージョン
        var ret: Code = seedRealm.readEqualAnd(Code.self
            , ofTypes: [Code.Types.kindCode.rawValue, Code.Types.code.rawValue]
            , forQuery: [[Const.Value.kindCode.VERSION] as AnyObject, [score.versionId] as AnyObject])
            .first ?? Code()
        versionLbl.text = ret.name
        
        // レベル、難易度
        ret = seedRealm.readEqualAnd(Code.self
        , ofTypes: [Code.Types.kindCode.rawValue, Code.Types.code.rawValue]
        , forQuery: [[Const.Value.kindCode.DIFFICULTY] as AnyObject, [score.difficultyId] as AnyObject])
        .first ?? Code()
        difficultyLbl.text = "☆\(score.level) \(ret.name!)"

        // タイトル
        var newLineTitle: String = CommonMethod.newLineString(str: score.title ?? "", separater: "(")
        newLineTitle = CommonMethod.newLineString(str: newLineTitle, separater: "～")
        titleLbl.text = newLineTitle
        
        // ジャンル
        genreLbl.text = score.genre
        // アーティスト
        artistLbl.text = score.artist
        
        //***********************
        // clearLumpPV toolbar
        let clToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let clCancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tapClCancelBtn))
        let clSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let clDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapClDoneBtn))
        clToolbar.setItems([clCancelItem, clSpacelItem, clDoneItem], animated: true)
        
        clearLumpTF.inputView = clearLumpPV
        clearLumpTF.inputAccessoryView = clToolbar
        
        // get clearLumps for PV
        clearLumps = seedRealm.readEqual(Code.self, ofTypes: Code.Types.kindCode.rawValue
            , forQuery: [Const.Value.kindCode.CLEAR_LUMP] as AnyObject)

        // get clearLump for init value
        ret = seedRealm.readEqualAnd(Code.self
        , ofTypes: [Code.Types.kindCode.rawValue, Code.Types.code.rawValue]
        , forQuery: [[Const.Value.kindCode.CLEAR_LUMP] as AnyObject, [score.clearLump] as AnyObject])
        .first ?? Code()

        clearLumpTF.text = ret.name
        clearLumpTF.tag = ret.code

        //***********************
        // djLevelPV toolbar
        let dlToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let dlCancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tapDlCancelBtn))
        let dlSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let dlDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapDlDoneBtn))
        dlToolbar.setItems([dlCancelItem, dlSpacelItem, dlDoneItem], animated: true)
        
        djLevelTF.inputView = djLevelPV
        djLevelTF.inputAccessoryView = dlToolbar
        
        // get djLevels for PV
        djLevels = seedRealm.readEqual(Code.self, ofTypes: Code.Types.kindCode.rawValue
            , forQuery: [Const.Value.kindCode.DJ_LEVEL] as AnyObject).sorted(byKeyPath: Code.Types.sort.rawValue)
        
        // get djLevels for init value
        ret = seedRealm.readEqualAnd(Code.self
        , ofTypes: [Code.Types.kindCode.rawValue, Code.Types.code.rawValue]
        , forQuery: [[Const.Value.kindCode.DJ_LEVEL] as AnyObject, [score.djLevel] as AnyObject])
        .first ?? Code()

        djLevelTF.text = ret.name
        djLevelTF.tag = ret.code

        //***********************
        // score keyboad toolbar
        let scoreToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let scoreCancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tapScoreCancelBtn))
        let scoreSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let scoreDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapScoreDoneBtn))
        scoreToolbar.setItems([scoreCancelItem, scoreSpacelItem, scoreDoneItem], animated: true)
        
        scoreTF.inputAccessoryView = scoreToolbar
        var s: String = score.score.components(separatedBy: "(")[0]
        if s == "0" {
            s = ""
        }
        scoreTF.text = s

        //***********************
        // misscount keyboad toolbar
        let mcToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let mcCancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tapMcCancelBtn))
        let mcSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let mcDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapMcDoneBtn))
        mcToolbar.setItems([mcCancelItem, mcSpacelItem, mcDoneItem], animated: true)
        
        missCountTF.inputAccessoryView = mcToolbar
        var missCnt: String = score.missCount
        if missCnt == Const.Label.Score.HYPHEN {
            missCnt = ""
        }
        missCountTF.text = missCnt

        //***********************
        // tagPV toolbar
        let tagToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let tagCancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tapTagCancelBtn))
        let tagSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let tagDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapTagDoneBtn))
        tagToolbar.setItems([tagCancelItem, tagSpacelItem, tagDoneItem], animated: true)

        tagTF.inputView = tagPV
        tagTF.inputAccessoryView = tagToolbar

        // get tags for PV
        tags = scoreRealm.readAll(Tag.self)
        
        // tag str -> tagArray for init value
        tagArray = score.tag?.components(separatedBy: ",") ?? [String]()
        tagArray.remove(value: "")
        for i in 0..<tagArray.count {
            tagArray[i] = String(tagArray[i].dropFirst())
            tagArray[i] = String(tagArray[i].dropLast())
        }
        
        // CVにレイアウトを設定
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8  // 横間隔
        layout.minimumLineSpacing = 8       // 縦間隔
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        tagCV.collectionViewLayout = layout
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /// 上にスワイプ
    @IBAction func swipeUp(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    
    /// tap Cancel Btn
    @IBAction func tapCancelBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    
    /// tap Save Btn
    @IBAction func tapSaveBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)

        // clearlump
        let clearLump: Int = clearLumpTF.tag
        // djlevel
        let djLevel: Int = djLevelTF.tag
        // score
        var s: String = scoreTF.text ?? ""
        if s == "" || s == "0" {
            s = Const.Label.Score.ZERO
        }
        // scoreRate
        let scoreRate: Double = CommonMethod.calcurateScoreRate(score: s, totalNotes: score.totalNotes)
        // misscount
        var missCount: String = missCountTF.text ?? ""
        if missCount == "" || missCount == "0" {
            missCount = Const.Label.Score.HYPHEN
        }
        // tag
        var tagStr: String = ""
        if !tagArray.isEmpty {
            for tag in tagArray {
                tagStr = tagStr + "," + "[" + tag + "]"
            }
            tagStr.remove(at: tagStr.startIndex)
        }

        // save DB
        scoreRealm.updateForDetail(score: score, clearLump: clearLump
            , djLevel: djLevel, s: s, scoreRate: scoreRate, missCount: missCount, tag: tagStr)
        
        // データ取得処理
        let vc: MainViewController = self.presentingViewController as! MainViewController
        let operation: Operation = Operation.init(mainVC: vc)
        let score: Results<MyScore> = operation.doOperation()
        // メイン画面のUI処理
        vc.mainUI()
        // リスト画面リロード
        let listVC: ListViewController
            = self.presentingViewController?.children[0] as! ListViewController
        listVC.scores = score
        listVC.listTV.reloadData()

        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
}


/// タグ一覧
extension EditDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return CGSize.zero
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        Log.debugStart(cls: String(describing: self), method: #function)

        var cgSize: CGSize!
        
        if indexPath.row == tagArray.count {
            cgSize = CGSize(width: 30, height: 30)
        } else {
            let label = UILabel(frame: CGRect.zero)
            label.font = UIFont.systemFont(ofSize: 14)
            label.text = tagArray[indexPath.row]
            label.sizeToFit()
            let size = label.frame.size
            cgSize = CGSize(width: size.width + 20, height: 30)
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cgSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return self.tagArray.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)

        if indexPath.row == tagArray.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as! TagAddCollectionViewCell
            // addBtn tap action
            cell.addBtn.tag = indexPath.row
            cell.addBtn.addTarget(self, action: #selector(tapAddBtn), for: .touchUpInside)
            
            Log.debugEnd(cls: String(describing: self), method: #function)
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TagCollectionViewCell
            cell.tagLbl.text = self.tagArray[indexPath.row]
            cell.layer.masksToBounds   = true
            cell.layer.cornerRadius    = 10
        
            // checkBtn tap action
            cell.tagBtn.tag = indexPath.row
            cell.tagBtn.addTarget(self, action: #selector(tapTagBtn), for: .touchUpInside)
            
            Log.debugEnd(cls: String(describing: self), method: #function)
            return cell
        }
    }
    
    
    /// ☓ボタンタップ時
    @objc private func tapTagBtn(_ sender:UIButton) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        let row: Int = sender.tag
        tagArray.remove(at: row)
        tagCV.reloadData()
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    /// 追加ボタンタップ時
    @objc private func tapAddBtn(_ sender:UIButton) {
        Log.debugStart(cls: String(describing: self), method: #function)

        // forcus to tagTF for picker
        tagTF.becomeFirstResponder()
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}

/// セルを左詰にするFlowLayout
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        Log.debugStart(cls: String(describing: self), method: #function)
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementCategory == .cell {
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                layoutAttribute.frame.origin.x = leftMargin
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return attributes
    }
}


/// picker view
extension EditDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)

        var cnt: Int = 0
        switch pickerView {
        case clearLumpPV:
            cnt = clearLumps.count
        case djLevelPV:
            cnt = djLevels.count
        case tagPV:
            cnt = tags.count
        default:
            fatalError()
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cnt
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Log.debugStart(cls: String(describing: self), method: #function)

        var item: String = ""
        switch pickerView {
        case clearLumpPV:
            item = clearLumps[row].name ?? ""
        case djLevelPV:
            item = djLevels[row].name ?? ""
        case tagPV:
            item = tags[row].tag ?? ""
        default:
            fatalError()
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return item
    }
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        self.clearLumpTF.text = list[row]
//        clearLumpTF.resignFirstResponder()
//    }
    
    
    /// Done button
    @objc func tapClDoneBtn() {
        clearLumpTF.endEditing(true)
        clearLumpTF.text
            = clearLumps[clearLumpPV.selectedRow(inComponent: 0)].name!
        clearLumpTF.tag = clearLumps[clearLumpPV.selectedRow(inComponent: 0)].code
    }
    
    /// Done button
    @objc func tapDlDoneBtn() {
        djLevelTF.endEditing(true)
        djLevelTF.text
            = djLevels[djLevelPV.selectedRow(inComponent: 0)].name!
        djLevelTF.tag = djLevels[djLevelPV.selectedRow(inComponent: 0)].code
    }

    /// Done button
    @objc func tapScoreDoneBtn() {
        scoreTF.endEditing(true)
    }

    /// Done button
    @objc func tapMcDoneBtn() {
        missCountTF.endEditing(true)
    }

    /// Done button
    @objc func tapTagDoneBtn() {
        tagTF.endEditing(true)
        tagArray.append(tags[tagPV.selectedRow(inComponent: 0)].tag ?? "")
        tagCV.reloadData()
    }
    
    /// cancel button
    @objc func tapClCancelBtn() {
        clearLumpTF.endEditing(true)
    }
    
    /// cancel button
    @objc func tapDlCancelBtn() {
        djLevelTF.endEditing(true)
    }
    
    /// cancel button
    @objc func tapScoreCancelBtn() {
        scoreTF.endEditing(true)
    }

    /// cancel button
    @objc func tapMcCancelBtn() {
        missCountTF.endEditing(true)
    }
    
    /// cancel button
    @objc func tapTagCancelBtn() {
        tagTF.endEditing(true)
    }
}
