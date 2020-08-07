//
//  StatisticsDLViewController.swift
//  IIDX
//
//  Created by umeme on 2019/09/04.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class StatisticsDLViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var clearLumpBtn: UIButton!
    @IBOutlet weak var statisticsView: UIView!
    @IBOutlet weak var statisticsTV: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var items: Results<Code>!
    var ratioDicArray: [[Int : [String]]] = [[Int : [String]]]()
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        statisticsTV.delegate = self
        statisticsTV.dataSource = self

        // ラインを左端まで引く
        statisticsTV.separatorInset = .zero
        
        // ボタンの装飾
        clearLumpBtn.backgroundColor = UIColor.darkGray
        clearLumpBtn.layer.borderWidth = 0.5
        clearLumpBtn.layer.borderColor = UIColor.darkGray.cgColor
        clearLumpBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        //左上を角丸にする設定
        clearLumpBtn.layer.cornerRadius = 15
        clearLumpBtn.layer.maskedCorners = [.layerMinXMinYCorner]

        // 項目名を取得
        let realm: MyRealm = MyRealm.init(path: CommonMethod.getSeedRealmPath())
        items = realm.readEqual(Code.self, ofTypes: Code.Types.kindCode.rawValue
            , forQuery: [Const.Value.kindCode.DJ_LEVEL] as AnyObject)
            .sorted(byKeyPath: Code.Types.sort.rawValue)
        
        // 現在表示されているデータを分析
        let vc: MainViewController = self.presentingViewController?.presentingViewController
            as! MainViewController
        let operation: Operation = Operation.init(mainVC: vc)
        let data: Results<MyScore> = operation.doOperation()
        let total = Double(data.count)
        
        // タイトル表示
        titleLbl.text = vc.titleLbl.text
        
        // 各項目の数
        var numArray: [Double] = [Double]()
        for item in items {
            let num: Double = Double(data.filter("\(MyScore.Types.djLevel.rawValue) = %@", item.code).count)
            numArray.append(num)
        }
        
        // 計算、円グラフ描写
        let ret = Calculate.doCalculate(total: total, items: items, numArray: numArray, view: self.statisticsView)
        
        self.statisticsView = ret.0
        ratioDicArray = ret.1
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    
    /// セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return items.count
    }
    
    
    /// セルを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:indexPath as IndexPath)
            as! StatisticsTableViewCell
        
        for (key, value) in ratioDicArray[indexPath.row] {
            // 項目名
            cell.itemLbl.text = items[indexPath.row].name
            // 数
            cell.numLbl.text = value[0]
            // レート
            cell.ratioLbl.text = value[1]
            
            // 色設定
            switch key {
            case Const.Value.DjLevel.AAA:
                cell.colorIV.backgroundColor = Const.Color.DjLevel.AAA
            case Const.Value.DjLevel.AA:
                cell.colorIV.backgroundColor = Const.Color.DjLevel.AA
            case Const.Value.DjLevel.A:
                cell.colorIV.backgroundColor = Const.Color.DjLevel.A
            case Const.Value.DjLevel.B:
                cell.colorIV.backgroundColor = Const.Color.DjLevel.B
            case Const.Value.DjLevel.C:
                cell.colorIV.backgroundColor = Const.Color.DjLevel.C
            case Const.Value.DjLevel.D:
                cell.colorIV.backgroundColor = Const.Color.DjLevel.D
            case Const.Value.DjLevel.E:
                cell.colorIV.backgroundColor = Const.Color.DjLevel.E
            case Const.Value.DjLevel.F:
                cell.colorIV.backgroundColor = Const.Color.DjLevel.F
            default:
                cell.colorIV.backgroundColor = Const.Color.DjLevel.F
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cell
    }

    
    /// セルをタップ
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        Log.debugStart(cls: String(describing: self), method: #function)
        // タップしたセルを取得
        if let cell: StatisticsTableViewCell
            = statisticsTV.cellForRow(at: indexPath) as? StatisticsTableViewCell {
            // 選択状態を解除
            cell.isSelected = false
            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }


    /// Closeボタン押下
    @IBAction func tapCloseBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    
    /// ClearLumpボタン押下
    @IBAction func tapCleaLumpBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }

    
    /// 上にスワイプ
    @IBAction func swipeUp(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func swipeRight(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    /// タッチイベント
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                self.presentingViewController?.dismiss(animated: false, completion: nil)
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}

