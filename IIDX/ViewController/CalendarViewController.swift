//
//  CalendarViewController.swift
//  IIDX
//
//  Created by umeme on 2022/08/21.
//  Copyright © 2022 umeme. All rights reserved.
//

import UIKit
import RealmSwift

//MARK:- Protocol
protocol ViewLogic {
    var numberOfWeeks: Int { get set }
    var daysArray: [String]! { get set }
}

class CalendarViewController: UIViewController, ViewLogic {
    
    @IBOutlet weak var listTV: UITableView!
    @IBOutlet weak var calendarCV: UICollectionView!
    @IBOutlet weak var monthView: UIView!
    @IBAction func prevBtn(_ sender: UIButton) { prevMonth() }
    @IBAction func nextBtn(_ sender: UIButton) { nextMonth() }
    @IBOutlet weak var monthLbl: UILabel!
    @IBAction func todayBtn(_ sender: UIButton) { todayMonth() }
    @IBOutlet weak var noDataMsgLbl: UILabel!
    
    let myUD: MyUserDefaults = MyUserDefaults()
    var scores: Results<OldScore>!
    var scoreDic: Dictionary = Dictionary<String, [OldScore]>()
    var keyArray: [String] = [String]()
    var scoreToDtail: OldScore!
    
    // カレンダー用
    var numberOfWeeks: Int = 0
    var daysArray: [String]!
    private var requestForCalendar: RequestForCalendar?
    private let date = DateItems.ThisMonth.Request()
    private let daysPerWeek = 7
    private var thisYear: Int = 0
    private var thisMonth: Int = 0
    private var today: Int = 0
    private var isToday = true
    private let dayOfWeekLabel = ["日", "月", "火", "水", "木", "金", "土"]
    private var monthCounter = 0
    private var moveYear: Int = 0
    private var moveMonth: Int = 0
    
    /**
     カレンダー用
     */
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dependencyInjection()
    }
    
    /**
     カレンダー用
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dependencyInjection()
    }
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        // カレンダー用
        configure()
        settingLabel()
        getToday()
        
        self.listTV.delegate = self
        self.listTV.dataSource = self
        
        // スコア取得
        getScore(firstDay: date.firstDay, lastDay: date.lastDay)
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /**
     カレンダー設定
     */
    private func dependencyInjection() {
        let viewController = self
        let calendarController = CalendarController()
        let calendarPresenter = CalendarPresenter()
        let calendarUseCase = CalendarUseCase()
        viewController.requestForCalendar = calendarController
        calendarController.calendarLogic = calendarUseCase
        calendarUseCase.responseForCalendar = calendarPresenter
        calendarPresenter.viewLogic = viewController
    }
    
    private func configure() {
        calendarCV.dataSource = self
        calendarCV.delegate = self
        requestForCalendar?.requestNumberOfWeeks(request: date)
        requestForCalendar?.requestDateManager(request: date)
    }
    
    private func settingLabel() {
        monthLbl.text = "\(String(date.year))年\(String(date.month))月"
    }
    
    private func getToday() {
        thisYear = date.year
        thisMonth = date.month
        today = date.day
    }
    
    /**
     スコア取得
     */
    private func getScore(firstDay: Date, lastDay: Date) {
        
        // スコア取得
        let operation = Operation.init()
        scores = operation.doCalendar(firstDay: firstDay, lastDay: lastDay)
        
        // スコアDic、日付配列初期化
        scoreDic.removeAll()
        keyArray.removeAll()
        
        // 日付ごとにスコアを分類
        if !scores.isEmpty {
            var scoreArray: [OldScore] = [OldScore]()
            var tmpPlayDate = ""
            for score in scores {
                let playDate: String = String(convertDate(date: score.playDate).prefix(10))
                if playDate == tmpPlayDate {
                    scoreArray.append(score)
                } else {
                    if !scoreArray.isEmpty {
                        scoreDic[tmpPlayDate] = scoreArray
                        scoreArray.removeAll()
                    }
                    scoreArray.append(score)
                }
                tmpPlayDate = playDate
            }
            scoreDic[tmpPlayDate] = scoreArray

            // キー（日付）配列
            keyArray = [String](scoreDic.keys)
            // キーをソート
            keyArray.sort()
            
//            // 今日分のスコアがある場合、今日の日付までスクロール
//            scroll(dateStr: String(dateStr.prefix(10)))
            
            noDataMsgLbl.isHidden = true
            
        } else {
            noDataMsgLbl.isHidden = false
        }
        // リロード
        listTV.reloadData()
    }
    
    /**
     Date -> String 変換
     */
    private func convertDate(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
//        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier:  "UTC")
//        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        return dateFormatter.string(from: date)
    }
    

    @IBAction func swipeRight(_ sender: Any) {
        prevMonth()
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        nextMonth()
    }
    
    @IBAction func tapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        
        let cnt = scoreDic[keyArray[section]]?.count
        label.text = "\(keyArray[section])  \(cnt ?? 0)件"

        // Viewデザイン
        let screenWidth:CGFloat = listTV.frame.size.width
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 0.5
        view.frame = CGRect(x:0, y:0, width:screenWidth, height:30)
        view.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        // labelデザイン
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 15)
        label.frame = CGRect(x:10, y:0, width:screenWidth-10, height:30)
        label.textColor = UIColor.darkGray
        
        view.addSubview(label)
        
        // セクションのビューに対応する番号を設定する
        view.tag = section
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return view
    }

    /*
     セクションの高さを返す
     */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return 30
    }

    /**
     セルの数を返す
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return scoreDic[keyArray[section]]?.count ?? 0
    }

    /**
     セルを返す
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! CalendarTableViewCell
        
        // スコア取得
        let scoreArray: [OldScore] = scoreDic[keyArray[indexPath.section]]!
        
        // レベル
        cell.levelLbl.text = String(scoreArray[indexPath.row].level)
        let color = CommonMethod.setLevel(arg: scoreArray[indexPath.row].difficultyId)
        cell.levelLbl.textColor = color
        // タイトル
        cell.titleLbl.text = scoreArray[indexPath.row].title

        // *** 更新後スコア
        // Clear Lump
        let updateClearLump = CommonMethod.setClearLump(arg: scoreArray[indexPath.row].updateClearLump)
        cell.updateClearLampIV.image = updateClearLump.image
        cell.updateClearLampIV.backgroundColor = updateClearLump.color
        // DjLevel
        let updateDjLevel = CommonMethod.setDjLevel(arg: scoreArray[indexPath.row].updateDjLevel)
        cell.updateDjLevelIV.image = updateDjLevel
        // スコア
        let score: String = CommonMethod.setScore(arg: String(describing: scoreArray[indexPath.row].updateScore))
        cell.updateScoreLbl.text = "score: \(score)"
        // ミスカウント
        var missCount: String = String(describing: scoreArray[indexPath.row].updateMissCount)
        if scoreArray[indexPath.row].updateMissCount == 9999 {
            missCount = Const.Label.Score.HYPHEN
        }
        cell.updateMissLbl.text = "miss: \(missCount)"
        // スコアレート
        let scoreRate: String = CommonMethod.setScoreRate(arg: scoreArray[indexPath.row].updateScoreRate)
        cell.updateScoreRateLbl.text = "rate: \(scoreRate)"
        // プラス・マイナス
        cell.updatePlusMinusLbl.text = scoreArray[indexPath.row].updatePlusMinus
        
        // *** 更新前スコア
        // Clear Lump
        let clearLamp = CommonMethod.setClearLump(arg: scoreArray[indexPath.row].clearLump)
        cell.clearLampIV.image = clearLamp.image
        cell.clearLampIV.backgroundColor = clearLamp.color
        // DjLevel
        if scoreArray[indexPath.row].updateDjLevel > scoreArray[indexPath.row].djLevel {
            let djLevel = CommonMethod.setDjLevel(arg: scoreArray[indexPath.row].djLevel)
            cell.djLevelIV.image = djLevel
            cell.djLevelIV.isHidden = false
        }

        // *** 差分
        // スコア
        let scoreDiff = scoreArray[indexPath.row].updateScore - scoreArray[indexPath.row].score
        if scoreDiff != 0 {
            cell.scoreDiffLbl.isHidden = false
            if scoreDiff > 0 {
                cell.scoreDiffLbl.text = "+\(scoreDiff)"
                cell.scoreDiffLbl.backgroundColor = .systemRed
            } else {
                cell.scoreDiffLbl.text = "\(scoreDiff)"
                cell.scoreDiffLbl.backgroundColor = .systemBlue
            }
        } else {
            cell.scoreDiffLbl.isHidden = true
        }
        // ミスカウント
        var missCnt = scoreArray[indexPath.row].missCount
        let updateMissCnt = scoreArray[indexPath.row].updateMissCount
        if updateMissCnt == 9999 {
            // ミスカウント未取り込み時差分は非表示
            cell.missDiffLbl.isHidden = true
        } else {
            if missCnt == 9999 {
                missCnt = 0
            }
            let missDiff = updateMissCnt - missCnt
            if missDiff != 0 {
                cell.missDiffLbl.isHidden = false
                if missDiff > 0 {
                    cell.missDiffLbl.text = "+\(missDiff)"
                    cell.missDiffLbl.backgroundColor = .systemRed
                } else {
                    cell.missDiffLbl.text = "\(missDiff)"
                    cell.missDiffLbl.backgroundColor = .systemBlue
                }
            } else {
                cell.missDiffLbl.isHidden = true
            }
        }
        
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cell
    }

    /**
     セルをタップ
     */
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // タップしたセルを取得
        if let cell: UITableViewCell = listTV.cellForRow(at: indexPath) {
            // 選択状態を解除
            cell.isSelected = false
        }
        // 詳細画面へ遷移
        let scoreArray: [OldScore] = scoreDic[keyArray[indexPath.section]]!
        scoreToDtail = scoreArray[indexPath.row]
        performSegue(withIdentifier: Const.Segue.TO_CALENDAR_DETAIL, sender: nil)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     データ渡し
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        Log.debugStart(cls: String(describing: self), method: #function)
        // 詳細画面にデータを渡す
        if segue.identifier == Const.Segue.TO_CALENDAR_DETAIL {
            let vc: CalendarDetailViewController = segue.destination as! CalendarDetailViewController
            vc.score = scoreToDtail
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     指定の日付までスクロールする
     */
    private func scroll(dateStr: String) {
        if let index = keyArray.firstIndex(of: dateStr) {
            let indexPath = IndexPath(row: 0, section: index)
            listTV.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}


extension CalendarViewController {
    
    /**
     翌月タップ
     */
    private func nextMonth() {
        monthCounter += 1
        commonSettingMoveMonth()
    }
    
    /**
     前月タップ
     */
    private func prevMonth() {
        monthCounter -= 1
        commonSettingMoveMonth()
    }
    
    /**
     今月タップ
     */
    private func todayMonth() {
        let thisDate = DateItems.ThisMonth.Request()
        requestForCalendar?.requestNumberOfWeeks(request: thisDate)
        requestForCalendar?.requestDateManager(request: thisDate)
        monthLbl.text = "\(String(thisDate.year))年\(String(thisDate.month))月"
        isToday = thisYear == thisDate.year && thisMonth == thisDate.month ? true : false

        calendarCV.reloadData()
        moveYear = thisDate.year
        moveMonth = thisDate.month
        monthCounter = 0

        // スコア取得
        getScore(firstDay: thisDate.firstDay, lastDay: thisDate.lastDay)
        
        self.collectionView(calendarCV, didSelectItemAt: IndexPath(row:30, section:1))
    }
    
    private func commonSettingMoveMonth() {
        daysArray = nil
        let moveDate = DateItems.MoveMonth.Request(monthCounter)
        requestForCalendar?.requestNumberOfWeeks(request: moveDate)
        requestForCalendar?.requestDateManager(request: moveDate)
        monthLbl.text = "\(String(moveDate.year))年\(String(moveDate.month))月"
        isToday = thisYear == moveDate.year && thisMonth == moveDate.month ? true : false
        calendarCV.reloadData()
        
        moveYear = moveDate.year
        moveMonth = moveDate.month
        
        // スコア取得
        getScore(firstDay: moveDate.firstDay, lastDay: moveDate.lastDay)
    }
    
}


extension CalendarViewController: UICollectionViewDataSource {
    /**
     セクションの数を返す
     */
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    /**
     セルの数を返す
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 7 : (numberOfWeeks * daysPerWeek)
    }
    
    /**
     セルを返す
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.backgroundColor = .clear
//        dayOfWeekColor(label, indexPath.row, daysPerWeek)
        showDate(indexPath.section, indexPath.row, cell, label)
        
        // イベントが有る日に印を付ける
        let view = cell.contentView.viewWithTag(2)!
        let dateStr = getDateStr(day: label.text ?? "")
        if keyArray.firstIndex(of: dateStr) != nil {
            view.isHidden = false
            label.textColor = .white
        } else {
            view.isHidden = true
            label.textColor = .darkGray
        }
        
        markToday(label)
        
        return cell
    }
    
    /**
     セルをタップ
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.section == 1 {
            if let cell = collectionView.cellForItem(at: indexPath) {
                let label = cell.contentView.viewWithTag(1) as! UILabel
                // スコアをスクロール
                let dateStr = getDateStr(day: label.text ?? "")
                scroll(dateStr: dateStr)
            }
        }
            
    }
    
    /**
     年月日文字列整形
     */
    private func getDateStr(day: String) -> String {
        let tmpDay = Int(day)
        let day: String = String(format: "%02d", tmpDay ?? "")
        var year: String = ""
        var month: String = ""
        if moveYear == 0 || moveMonth == 0 {
            year = String(thisYear)
            month = String(format: "%02d", thisMonth)
        } else {
            year = String(moveYear)
            month = String(format: "%02d", moveMonth)
        }
        let dateStr = "\(year)/\(month)/\(day)"
        return dateStr
    }
    
    /**
     曜日で色を変える（未使用）
     */
    private func dayOfWeekColor(_ label: UILabel, _ row: Int, _ daysPerWeek: Int) {
        switch row % daysPerWeek {
        case 0: label.textColor = .red
        case 6: label.textColor = .blue
        default: label.textColor = .black
        }
    }

    /**
     セル選択時のデザイン
     */
    private func showDate(_ section: Int, _ row: Int, _ cell: UICollectionViewCell, _ label: UILabel) {
        switch section {
        case 0:
            label.text = dayOfWeekLabel[row]
            cell.selectedBackgroundView = nil
        default:
            label.text = daysArray[row]
            // 選択セルの枠を表示
            let selectedView = UIView()
            selectedView.layer.borderWidth = 1
            selectedView.layer.borderColor = UIColor.darkGray.cgColor
            cell.selectedBackgroundView = selectedView
        }
    }
    
    /**
     今日の日付のデザイン
     */
    private func markToday(_ label: UILabel) {
        if isToday, today.description == label.text {
            label.textColor = .systemRed
        }
    }
}


extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let weekWidth = Int(collectionView.frame.width) / daysPerWeek
        let weekHeight = weekWidth - 20
        let dayWidth = weekWidth
        let dayHeight = (Int(collectionView.frame.height) - weekHeight) / numberOfWeeks
        return indexPath.section == 0 ? CGSize(width: weekWidth, height: weekHeight) : CGSize(width: dayWidth, height: dayHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let surplus = Int(collectionView.frame.width) % daysPerWeek
        let margin = CGFloat(surplus)/2.0
        return UIEdgeInsets(top: 0.0, left: margin, bottom: 1.5, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
