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

//MARK:- Protocol
protocol ViewLogic {
    var numberOfWeeks: Int { get set }
    var daysArray: [String]! { get set }
}

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource, ViewLogic{
    
    @IBOutlet weak var listTV: UITableView!
    @IBOutlet weak var calendarCV: UICollectionView!
    @IBOutlet weak var monthView: UIView!
    @IBAction func prevBtn(_ sender: UIButton) { prevMonth() }
    @IBAction func nextBtn(_ sender: UIButton) { nextMonth() }
    @IBOutlet weak var monthLbl: UILabel!
    
    
    let myUD: MyUserDefaults = MyUserDefaults()

    var scores: Results<OldScore>!
    var scoreDic: Dictionary = Dictionary<String, [OldScore]>()
    var keyArray: [String] = [String]()
    
    //MARK: Properties
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
    
    //MARK: Initialize
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dependencyInjection()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dependencyInjection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configure()
        settingLabel()
        getToday()
        
        self.listTV.delegate = self
        self.listTV.dataSource = self
        
        // スコア取得
        getScore(firstDay: date.firstDay, lastDay: date.lastDay)
    }
    
    
    //MARK: Setting
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
        return 30
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
        let scoreArray: [OldScore] = scoreDic[keyArray[indexPath.section]]!
        
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
        
//        // 前作ゴースト
//        // スコア
//        let ghostScore = CommonMethod.setScore(arg: String(describing: scoreArray[indexPath.row].ghostScore))
//        cell.ghostScoreLbl.text = "score: \(ghostScore)"
//        // スコアレート
//        let ghostScoreRate = CommonMethod.setScoreRate(arg: scoreArray[indexPath.row].ghostScoreRate)
//        cell.ghostScoreRateLbl.text = "rate: \(ghostScoreRate)"
//        // ミスカウント
//        var ghostMissCount: String = String(describing: scoreArray[indexPath.row].ghostMissCount)
//        if scores[indexPath.row].ghostMissCount == 9999 {
//            ghostMissCount = Const.Label.Score.HYPHEN
//        }
//        cell.ghostMissLbl.text = "miss: \(ghostMissCount)"
//        // プラス・マイナス
//        cell.ghostPlusMinusLbl.text = scoreArray[indexPath.row].ghostPlusMinus

        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cell
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
    
    private func getScore(firstDay: Date, lastDay: Date) {
        
        let date = Date()
        // Date -> String変換
        let dateStr = convertDate(date: date)
        // スコア取得
        let operation = Operation.init()
        scores = operation.doCalendar(firstDay: firstDay, lastDay: lastDay)
        
        // スコアDic、日付配列初期化
        scoreDic.removeAll()
        keyArray.removeAll()
        
        // 日付ごとにスコアを分類
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

        // ソートできない・・
//        scoreDic.sorted(by: { $0.key < $1.key})
        // キー（日付）配列
        keyArray = [String](scoreDic.keys)
        // キーをソート
        keyArray.sort()
        
        // リロード
        listTV.reloadData()
        
        // 今日分のスコアがある場合、今日の日付までスクロール
        scroll(dateStr: String(dateStr.prefix(10)))

    }
}


//MARK:- Setting Button Items
extension CalendarViewController {
    
    private func nextMonth() {
        monthCounter += 1
        commonSettingMoveMonth()
    }
    
    private func prevMonth() {
        monthCounter -= 1
        commonSettingMoveMonth()
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


//MARK:- UICollectionViewDataSource
extension CalendarViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 7 : (numberOfWeeks * daysPerWeek)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.backgroundColor = .clear
        dayOfWeekColor(label, indexPath.row, daysPerWeek)
        showDate(indexPath.section, indexPath.row, cell, label)
        
        // イベントが有る日に印を付ける
        let label2 = cell.contentView.viewWithTag(2) as! UILabel
        let dateStr = getDateStr(day: label.text ?? "")
        if keyArray.firstIndex(of: dateStr) != nil {
            label2.isHidden = false
        } else {
            label2.isHidden = true
        }
        
        return cell
    }
    
    // セルがタップされたとき
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.section == 1 {
            if let cell = collectionView.cellForItem(at: indexPath) {
                let label = cell.contentView.viewWithTag(1) as! UILabel
                let dateStr = getDateStr(day: label.text ?? "")
                scroll(dateStr: dateStr)
            }
        }
            
    }
    
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
    
    private func dayOfWeekColor(_ label: UILabel, _ row: Int, _ daysPerWeek: Int) {
        switch row % daysPerWeek {
        case 0: label.textColor = .red
        case 6: label.textColor = .blue
        default: label.textColor = .black
        }
    }

    private func showDate(_ section: Int, _ row: Int, _ cell: UICollectionViewCell, _ label: UILabel) {
        switch section {
        case 0:
            label.text = dayOfWeekLabel[row]
            cell.selectedBackgroundView = nil
        default:
            label.text = daysArray[row]
            let selectedView = UIView()
            selectedView.backgroundColor = .mercury()
            cell.selectedBackgroundView = selectedView
            markToday(label)
        }
    }
    
    private func markToday(_ label: UILabel) {
        if isToday, today.description == label.text {
            label.backgroundColor = .myLightRed()
        }
    }
    
}


//MARK:- UICollectionViewDelegateFlowLayout
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
