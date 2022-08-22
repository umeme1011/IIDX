//
//  CalendarViewController.swift
//  IIDX
//
//  Created by umeme on 2022/08/21.
//  Copyright © 2022 umeme. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift

class CalenderViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var listTV: UITableView!
    
    let myUD: MyUserDefaults = MyUserDefaults()

    var scores: Results<MyScore>!
    var scoreDic: Dictionary = Dictionary<String, [MyScore]>()
    var keyArray: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar.dataSource = self
        self.calendar.delegate = self
        
        listTV.delegate = self
        listTV.dataSource = self
        
        // 今月プレイ分のスコアを取得
        let date = Date()
        let operation = Operation.init()
        scores = operation.doCalendar(date: date)
        
        // 日付ごとにスコアを分類
        var scoreArray: [MyScore] = [MyScore]()
        var tmpDayStr = ""
        for score in scores {
            var dayStr: String = String(score.lastPlayDate?.prefix(10) ?? "")
            if dayStr == tmpDayStr {
                scoreArray.append(score)
            } else {
                if !scoreArray.isEmpty {
                    scoreDic[tmpDayStr] = scoreArray
                    scoreArray.removeAll()
                }
                scoreArray.append(score)
            }
            tmpDayStr = dayStr
        }

        // ソートできない・・
//        scoreDic.sorted(by: { $0.key < $1.key})
        // キー（日付）配列
        keyArray = [String](scoreDic.keys)
    }
    
    /*
     セクションの数を返す
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return keyArray.count
    }

    /*
     セクションのUIViewを返す
     */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        Log.debugStart(cls: String(describing: self), method: #function)
        let view: UIView = UIView()
        let label: UILabel = UILabel()
        
        label.text = keyArray[section]

//        // Viewデザイン
//        let screenWidth:CGFloat = filterView.frame.size.width
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 0.5
//        view.frame = CGRect(x:0, y:0, width:screenWidth, height:35)
        view.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
//        // labelデザイン
//        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 15)
//        label.frame = CGRect(x:10, y:0, width:screenWidth-10, height:35)
        label.textColor = UIColor.darkGray
        
        view.addSubview(label)
        
        // セクションのビューに対応する番号を設定する
        view.tag = section
        
        // セクションのビューにタップジェスチャーを設定する
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapHeader(gestureRecognizer:))))
        
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

    
    /// セルの数を返す test
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return scoreDic[keyArray[section]]?.count ?? 0
    }

    /// セルを返す test
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! ListTableViewCell
        
        // スコア取得
        let scoreArray: [MyScore] = scoreDic[keyArray[indexPath.section]]!
        
        // Clear Lump
        let ret = CommonMethod.setClearLump(arg: scoreArray[indexPath.row].clearLump)
        cell.clearLumpIV.image = ret.image
        cell.clearLumpIV.backgroundColor = ret.color
        // DjLevel
        let image = CommonMethod.setDjLevel(arg: scoreArray[indexPath.row].djLevel)
        cell.djLevelIV.image = image
        // レベル
        cell.levelLbl.text = String(scoreArray[indexPath.row].level)
        let color = CommonMethod.setLevel(arg: scoreArray[indexPath.row].difficultyId)
        cell.levelLbl.textColor = color
        // タイトル
        cell.titleLbl.text = scores[indexPath.row].title
        // スコア
        let score: String = CommonMethod.setScore(arg: String(describing: scoreArray[indexPath.row].score))
        cell.scoreLbl.text = "score: \(score)"
        // ミスカウント
        var missCount: String = String(describing: scoreArray[indexPath.row].missCount)
        if scores[indexPath.row].missCount == 9999 {
            missCount = Const.Label.Score.HYPHEN
        }
        cell.missLbl.text = "miss: \(missCount)"
        // スコアレート
        let scoreRate: String = CommonMethod.setScoreRate(arg: scoreArray[indexPath.row].scoreRate)
        cell.scoreRateLbl.text = "rate: \(scoreRate)"
        // プラス・マイナス
        cell.plusMinusLbl.text = scoreArray[indexPath.row].plusMinus
        
        // 前作ゴースト
        // スコア
        let ghostScore = CommonMethod.setScore(arg: String(describing: scoreArray[indexPath.row].ghostScore))
        cell.ghostScoreLbl.text = "score: \(ghostScore)"
        // スコアレート
        let ghostScoreRate = CommonMethod.setScoreRate(arg: scoreArray[indexPath.row].ghostScoreRate)
        cell.ghostScoreRateLbl.text = "rate: \(ghostScoreRate)"
        // ミスカウント
        var ghostMissCount: String = String(describing: scoreArray[indexPath.row].ghostMissCount)
        if scores[indexPath.row].ghostMissCount == 9999 {
            ghostMissCount = Const.Label.Score.HYPHEN
        }
        cell.ghostMissLbl.text = "miss: \(ghostMissCount)"
        // プラス・マイナス
        cell.ghostPlusMinusLbl.text = scoreArray[indexPath.row].ghostPlusMinus

        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cell
    }


    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
    }


}


