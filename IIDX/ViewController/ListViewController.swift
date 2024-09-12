//
//  ListViewController.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var listTV: UITableView!
    
    var mainVC: MainViewController = MainViewController()
    var scores: Results<MyScore>!
    var score: MyScore!
    var editScoreArray: [MyScore] = [MyScore]()
    
    let myUD: MyUserDefaults = MyUserDefaults()

    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        listTV.delegate = self
        listTV.dataSource = self
        
        // 長押し用
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressRecognizer.allowableMovement = 15
        longPressRecognizer.minimumPressDuration = 0.6
        listTV.addGestureRecognizer(longPressRecognizer)
        
        // ラインを左端まで引く
        listTV.separatorInset = .zero
        
        // セルの高さ
        changeRowHeight()
        
        // スコアデータ取得
        let operation: Operation = Operation.init(mainVC: mainVC)
        scores = operation.doOperation()

        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    
    /// セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return scores.count
    }
    
    
    /// セルを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! ListTableViewCell
        
        // Clear Lump
        let ret = CommonMethod.setClearLump(arg: scores[indexPath.row].clearLump)
        cell.clearLumpIV.image = ret.image
        cell.clearLumpIV.backgroundColor = ret.color
        // DjLevel
        let image = CommonMethod.setDjLevel(arg: scores[indexPath.row].djLevel)
        cell.djLevelIV.image = image
        // レベル
        cell.levelLbl.text = String(scores[indexPath.row].level)
        let color = CommonMethod.setLevel(arg: scores[indexPath.row].difficultyId)
        cell.levelLbl.textColor = color
        // タイトル
        cell.titleLbl.text = scores[indexPath.row].title
        // スコア
        let score: String = CommonMethod.setScore(arg: String(describing: scores[indexPath.row].score))
        cell.scoreLbl.text = "score: \(score)"
        // ミスカウント
        var missCount: String = String(describing: scores[indexPath.row].missCount)
        if scores[indexPath.row].missCount == 9999 {
            missCount = Const.Label.Score.HYPHEN
        }
        cell.missLbl.text = "miss: \(missCount)"
        // スコアレート
        let scoreRate: String = CommonMethod.setScoreRate(arg: scores[indexPath.row].scoreRate)
        cell.scoreRateLbl.text = "rate: \(scoreRate)"
        // プラス・マイナス
        cell.plusMinusLbl.text = scores[indexPath.row].plusMinus
        
        // 前作ゴースト
        // スコア
        let ghostScore = CommonMethod.setScore(arg: String(describing: scores[indexPath.row].ghostScore))
        cell.ghostScoreLbl.text = "score: \(ghostScore)"
        // スコアレート
        let ghostScoreRate = CommonMethod.setScoreRate(arg: scores[indexPath.row].ghostScoreRate)
        cell.ghostScoreRateLbl.text = "rate: \(ghostScoreRate)"
        // ミスカウント
        var ghostMissCount: String = String(describing: scores[indexPath.row].ghostMissCount)
        if scores[indexPath.row].ghostMissCount == 9999 {
            ghostMissCount = Const.Label.Score.HYPHEN
        }
        cell.ghostMissLbl.text = "miss: \(ghostMissCount)"
        // プラス・マイナス
        cell.ghostPlusMinusLbl.text = scores[indexPath.row].ghostPlusMinus

        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cell
    }
        
    
    /// セルタップ時
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // タップしたセルを取得
        if let cell: UITableViewCell = listTV.cellForRow(at: indexPath) {
            // 選択状態を解除
            cell.isSelected = false
        }
        // 詳細画面へ遷移
        score = scores[indexPath.row]
        performSegue(withIdentifier: Const.Segue.TO_DETAIL, sender: nil)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// 右から左へスワイプ
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let artistCopy = UIContextualAction(style: .normal,
                                            title: "Artist",
                                            handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
            // タイトルをクリップボードにコピー
            let artist: String = self.scores[indexPath.row].artist ?? ""
            UIPasteboard.general.string = artist
            // アラートを表示
            CommonMethod.dispAlert(message: "\(artist)\n\nをコピーしました。", vc: self)
            success(true)
        })
        artistCopy.backgroundColor = UIColor.systemRed

        let titleCopy = UIContextualAction(style: .normal,
                                            title: "Title",
                                            handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
            // タイトルをクリップボードにコピー
            let title: String = self.scores[indexPath.row].title ?? ""
            UIPasteboard.general.string = title
            // アラートを表示
            CommonMethod.dispAlert(message: "\(title)\n\nをコピーしました。", vc: self)
            success(true)
        })
        titleCopy.backgroundColor = UIColor.systemBlue

        return UISwipeActionsConfiguration(actions: [artistCopy, titleCopy])
    }

    
    /// セル長押し時
    @objc func longPress(_ sender: UILongPressGestureRecognizer){
        Log.debugStart(cls: String(describing: self), method: #function)
        let point: CGPoint = sender.location(in: listTV)
        let indexPath = listTV.indexPathForRow(at: point)
        
        if let indexPath = indexPath {
            if sender.state == UIGestureRecognizer.State.began {
                // 編集詳細画面へ遷移
                score = scores[indexPath.row]
                performSegue(withIdentifier: Const.Segue.TO_EDIT_DETAIL, sender: nil)
            }
        }else{
            return
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// cellのチェックボタンタップ時
    @objc private func tapCheckBtn(_ sender:UIButton) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        let row: Int = sender.tag
        if sender.backgroundImage(for: .normal) == UIImage(named: Const.Image.CHECK_OFF) {
            sender.setBackgroundImage(UIImage(named: Const.Image.CHECK_ON), for: .normal)
            editScoreArray.append(scores[row])
        } else {
//            sender.setBackgroundImage(nil, for: .normal)
            sender.setBackgroundImage(UIImage(named: Const.Image.CHECK_OFF), for: .normal)
            editScoreArray.remove(value: scores[row])
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    
    /// データ渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        Log.debugStart(cls: String(describing: self), method: #function)
        // 詳細画面にデータを渡す
        if segue.identifier == Const.Segue.TO_DETAIL {
            let vc: DetailViewController = segue.destination as! DetailViewController
            vc.score = score
        }
        // 編集詳細画面にデータを渡す
        if segue.identifier == Const.Segue.TO_EDIT_DETAIL {
            let vc: EditDetailViewController = segue.destination as! EditDetailViewController
            vc.score = score
        }

        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    func changeRowHeight() {
        // セルの高さ
        if myUD.getGhostDispFlg() {
            listTV.rowHeight = 49
        } else {
            listTV.rowHeight = 35
        }
    }
}
