//
//  DetailViewController.swift
//  IIDX
//
//  Created by umeme on 2019/09/06.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var difficultyLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var selectCntLbl: UILabel!
    @IBOutlet weak var scoreTV: UITableView!
    
    var score: MyScore!
    
    struct DetailScore {
        var djName: String
        var djLevel: Int
        var score: String
        var scoreRate: String
        var clearLump: Int
        var missCount: String
    }
    var scoreArray: [DetailScore] = [DetailScore]()

    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()

        scoreTV.delegate = self
        scoreTV.dataSource = self
        
        let scoreRealm: MyRealm = MyRealm.init(path: CommonMethod.getScoreRealmPath())
        let seedRealm: MyRealm = MyRealm.init(path: CommonMethod.getSeedRealmPath())
        
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
        difficultyLbl.text = "☆\(score.level) \(ret.name ?? "")"

        // タイトル
        var newLineTitle: String = CommonMethod.newLineString(str: score.title ?? "", separater: "(")
        newLineTitle = CommonMethod.newLineString(str: newLineTitle, separater: "～")
        titleLbl.text = newLineTitle
        
        // ジャンル
        genreLbl.text = score.genre
        // アーティスト
        artistLbl.text = score.artist
        
        // スコア表示データ作成
        var detailScore: DetailScore!
        // 自分
        let myStatus: MyStatus = scoreRealm.readAll(MyStatus.self).first ?? MyStatus()
        var dn: String = myStatus.djName ?? ""
        var dl: Int = score.djLevel
        var s: String = convertHyphenStr(s: score.score )
        var sr: String = makeScoreRateStr(scoreRate: score.scoreRate)
        var cl: Int = score.clearLump
        var mc: String = score.missCount
        detailScore = DetailScore(djName: dn, djLevel: dl, score: s, scoreRate: sr, clearLump: cl, missCount: mc)
        scoreArray.append(detailScore)
        
        // 自分（過去スコア）
        if let oldScore: OldScore
            = scoreRealm.readEqual(OldScore.self, ofTypes: OldScore.Types.id.rawValue
                , forQuery: [score.oldScoreId] as AnyObject).first {
            dn = (myStatus.djName ?? "") + "\n" + Const.Label.Score.OLD_SCORE
            dl = oldScore.djLevel
            s = convertHyphenStr(s: oldScore.score ?? "")
            sr = makeScoreRateStr(scoreRate: oldScore.scoreRate)
            cl = oldScore.clearLump
            mc = oldScore.missCount ?? ""
            detailScore = DetailScore(djName: dn, djLevel: dl, score: s, scoreRate: sr, clearLump: cl, missCount: mc)
            scoreArray.append(detailScore)
            
            // newスコアのDJNAMEに(new)をつける
            scoreArray[0].djName = scoreArray[0].djName + "\n" + Const.Label.Score.NEW_SCORE
        }
        
        // ライバル
        let rivals: Results<RivalStatus> = scoreRealm.readAllByPlayStyle(RivalStatus.self)
        for rival in rivals {
            let rivalScores: Results<RivalScore> = scoreRealm.readEqualAndByPlayStyle(RivalScore.self
                , ofTypes: [RivalScore.Types.iidxId.rawValue, RivalScore.Types.title.rawValue
                    , RivalScore.Types.difficultyId.rawValue, RivalScore.Types.level.rawValue]
                , forQuery: [[rival.iidxId] as AnyObject, [score.title] as AnyObject
                    , [score.difficultyId] as AnyObject, [score.level] as AnyObject])
            if !rivalScores.isEmpty {
                let rivalScore: RivalScore = rivalScores.first ?? RivalScore()
                dn = rival.djName ?? ""
                dl = rivalScore.djLevel
                s = convertHyphenStr(s: rivalScore.score ?? "")
                sr = makeScoreRateStr(scoreRate: rivalScore.scoreRate)
                cl = rivalScore.clearLump
                mc = rivalScore.missCount ?? ""
                detailScore = DetailScore(djName: dn, djLevel: dl, score: s, scoreRate: sr, clearLump: cl, missCount: mc)
                scoreArray.append(detailScore)
            }
        }
        
        // スコア順にソート
        scoreArray = scoreArray.sorted{(a:DetailScore, b:DetailScore) -> Bool in
            let aScore: Int = Int(a.score.components(separatedBy: "\n")[0]) ?? -1
            let bScore: Int = Int(b.score.components(separatedBy: "\n")[0]) ?? -1
            if aScore == bScore {
                // 第二ソート：ミスカウント昇順
                return a.missCount < b.missCount
            } else {
                // 第一ソート：スコア降順
                return aScore > bScore
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    
    /// セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return scoreArray.count
    }
    
    
    /// セルを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! DetailTableViewCell

        let detailScore: DetailScore = scoreArray[indexPath.row]
        cell.djNameLbl.text = detailScore.djName
        cell.missCntLbl.text = detailScore.missCount
        
        // スコア
        if detailScore.score == Const.Label.Score.HYPHEN {
            cell.scoreLbl.text = detailScore.score
        } else {
            cell.scoreLbl.text = detailScore.score + "\n" + detailScore.scoreRate
        }
        
        // クリアランプ
        var color: UIColor!
        var text: String!
        var image: UIImage!
        var textColor: UIColor = UIColor.darkGray
        switch detailScore.clearLump {
        case Const.Value.ClearLump.FCOMBO:
            color = nil
            text = Const.Label.ClearLump.FCOMBO.rawValue
            image = UIImage(named: Const.Image.FCOMBO_DETAIL)
            textColor = UIColor.white
        case Const.Value.ClearLump.EXHCLEAR:
            color = Const.Color.ClearLump.EXHCLEAR
            text = Const.Label.ClearLump.EXHARD.rawValue
            image = nil
        case Const.Value.ClearLump.HCLEAR:
            color = Const.Color.ClearLump.HCLEAR
            text = Const.Label.ClearLump.HARD.rawValue
            image = nil
        case Const.Value.ClearLump.CLEAR:
            color = Const.Color.ClearLump.CLEAR
            text = Const.Label.ClearLump.CLEAR.rawValue
            image = nil
        case Const.Value.ClearLump.ECLEAR:
            color = Const.Color.ClearLump.ECLEAR
            text = Const.Label.ClearLump.EASY.rawValue
            image = nil
        case Const.Value.ClearLump.ACLEAR:
            color = Const.Color.ClearLump.ACLEAR
            text = Const.Label.ClearLump.AEASY.rawValue
            image = nil
        case Const.Value.ClearLump.FAILED:
            color = Const.Color.ClearLump.FAILED
            text = Const.Label.ClearLump.FAILED.rawValue
            image = nil
        case Const.Value.ClearLump.NOPLAY:
            color = Const.Color.ClearLump.NOPLAY
            text = Const.Label.ClearLump.NOPLAY.rawValue
            image = nil
        default:
            color = Const.Color.ClearLump.NOPLAY
            text = Const.Label.ClearLump.NOPLAY.rawValue
            image = nil
        }
        cell.clearLumpLbl.backgroundColor = color
        cell.clearLumpLbl.text = text
        cell.clearLumpIV.image = image
        cell.clearLumpLbl.textColor = textColor
        
        
        // DJレベル
        switch detailScore.djLevel {
        case Const.Value.DjLevel.F:
            image = UIImage(named: Const.Image.DjLevel.F)
        case Const.Value.DjLevel.E:
            image = UIImage(named: Const.Image.DjLevel.E)
        case Const.Value.DjLevel.D:
            image = UIImage(named: Const.Image.DjLevel.D)
        case Const.Value.DjLevel.C:
            image = UIImage(named: Const.Image.DjLevel.C)
        case Const.Value.DjLevel.B:
            image = UIImage(named: Const.Image.DjLevel.B)
        case Const.Value.DjLevel.A:
            image = UIImage(named: Const.Image.DjLevel.A)
        case Const.Value.DjLevel.AA:
            image = UIImage(named: Const.Image.DjLevel.AA)
        case Const.Value.DjLevel.AAA:
            image = UIImage(named: Const.Image.DjLevel.AAA)
        default:
            image = nil
        }
        cell.djLevelIV.image = image
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cell
    }
    
    
    /// セルタップ時
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        Log.debugStart(cls: String(describing: self), method: #function)
       // タップしたセルを取得
        if let cell: DetailTableViewCell = scoreTV.cellForRow(at: indexPath)
            as? DetailTableViewCell {
            // 選択状態を解除
            cell.isSelected = false
            // 閉じる
            Log.debugEnd(cls: String(describing: self), method: #function)
            dismiss(animated: false, completion: nil)
        }
    }

    
    /// タッチイベント
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                self.dismiss(animated: false, completion: nil)
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// Closeボタン押下
    @IBAction func tapCloseBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    
    /// 上にスワイプ
    @IBAction func swipeUp(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    
    /// スコアが"0(0/0)"の場合は"-"に変換する
    private func convertHyphenStr(s: String) -> String {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret: String = ""
        if s == Const.Label.Score.ZERO {
            ret = Const.Label.Score.HYPHEN
        } else {
            ret = s.components(separatedBy: "(")[0]
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
    
    
    /// スコアレート文字列作成
    private func makeScoreRateStr(scoreRate: Double) -> String {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret: String = ""
        if scoreRate != 0 {
            ret = "(\(String(format: "%.2f", scoreRate))%)"
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
}
