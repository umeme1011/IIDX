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
    @IBOutlet weak var scoreTV: UITableView!
    
    // 次のページ
    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var sp1PBtn: UIButton!
    @IBOutlet weak var sp2PBtn: UIButton!
    @IBOutlet weak var dpBtn: UIButton!
    @IBOutlet weak var bpmLbl: UILabel!
    @IBOutlet weak var totalNotesLbl: UILabel!
    @IBOutlet weak var cnLbl: UILabel!
    @IBOutlet weak var clearLampLbl: UILabel!
    @IBOutlet weak var djLevelLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var pgreateLbl: UILabel!
    @IBOutlet weak var greateLbl: UILabel!
    @IBOutlet weak var missLbl: UILabel!
    @IBOutlet weak var playCntLbl: UILabel!
    @IBOutlet weak var lastPalyDateLbl: UILabel!
    
    
    var score: MyScore!
    let myUD: MyUserDefaults = MyUserDefaults()
    
    struct DetailScore {
        var djName: String
        var djLevel: Int
        var score: String
        var scoreRate: String
        var clearLump: Int
        var plusMinus: String
        var missCount: Int
    }
    var scoreArray: [DetailScore] = [DetailScore]()
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()

        scoreTV.delegate = self
        scoreTV.dataSource = self
        
        let scoreRealm: Realm = CommonMethod.createScoreRealm()
        let seedRealm: Realm = CommonMethod.createSeedRealm()
        
        // NextView非表示
        nextView.isHidden = true
        // nextボタンの文言変更
        nextBtn.setTitle("Next ▶", for: .normal)
        // 譜面ボタン切り替え
        if myUD.getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            sp1PBtn.isHidden = true
            sp2PBtn.isHidden = true
            dpBtn.isHidden = false
        } else {
            sp1PBtn.isHidden = false
            sp2PBtn.isHidden = false
            dpBtn.isHidden = true
        }

        // バージョン
        var ret: Code = seedRealm.objects(Code.self)
            .filter("\(Code.Types.kindCode.rawValue) = %@ and \(Code.Types.code.rawValue) = %@", Const.Value.kindCode.VERSION, score.versionId).first ?? Code()
        versionLbl.text = ret.name
        
        // レベル、難易度
        ret = seedRealm.objects(Code.self)
            .filter("\(Code.Types.kindCode.rawValue) = %@ and \(Code.Types.code.rawValue) = %@", Const.Value.kindCode.DIFFICULTY, score.difficultyId).first ?? Code()
        difficultyLbl.text = "☆\(score.level) \(ret.name ?? "")"

        // タイトル
        if score.title == "ASIAN VIRTUAL REALITIES (MELTING TOGETHER IN DAZZLING DARKNESS)" {   // 長過ぎるので改行なし
            titleLbl.text = score.title
        } else {
            var newLineTitle: String = CommonMethod.newLineString(str: score.title ?? "", separater: "(")
            newLineTitle = CommonMethod.newLineString(str: newLineTitle, separater: "～")
            titleLbl.text = newLineTitle
        }
        
        // ジャンル
        genreLbl.text = score.genre
        // アーティスト
        artistLbl.text = score.artist
        
        // スコア表示データ作成
        var detailScore: DetailScore!
        // 自分
        let myStatus: MyStatus = scoreRealm.objects(MyStatus.self).first ?? MyStatus()
        // 初期状態の場合は何も表示しない
        if myStatus.djName == nil {
            return
        }
        var dn: String = myStatus.djName ?? ""
        var dl: Int = score.djLevel
        var s: String = convertHyphenStr(s: score.score )
        var sr: String = makeScoreRateStr(scoreRate: score.scoreRate)
        var cl: Int = score.clearLump
        var pm: String = score.plusMinus ?? ""
        var mc: Int = score.missCount
        detailScore = DetailScore(djName: dn, djLevel: dl, score: s, scoreRate: sr, clearLump: cl, plusMinus: pm, missCount: mc)
        scoreArray.append(detailScore)
        
        // 自分（過去スコア）
        if let oldScore: OldScore = scoreRealm.objects(OldScore.self)
            .filter("\(OldScore.Types.id.rawValue) = %@", score.oldScoreId).first {
            
            dn = (myStatus.djName ?? "") + "\n" + Const.Label.Score.OLD_SCORE
            dl = oldScore.djLevel
            s = convertHyphenStr(s: oldScore.score)
            sr = makeScoreRateStr(scoreRate: oldScore.scoreRate)
            cl = oldScore.clearLump
            pm = oldScore.plusMinus ?? ""
            mc = oldScore.missCount
            detailScore = DetailScore(djName: dn, djLevel: dl, score: s, scoreRate: sr, clearLump: cl, plusMinus: pm, missCount: mc)
            scoreArray.append(detailScore)
            
            // newスコアのDJNAMEに(new)をつける
            scoreArray[0].djName = scoreArray[0].djName + "\n" + Const.Label.Score.NEW_SCORE
        }

        // 前作ゴーストフラグ表示ありの場合のみ表示
        if myUD.getGhostDispFlg() {
            dn = (myStatus.djName ?? "") + "\n" + Const.Label.Score.GHOST_SCORE
            dl = score.ghostDjLevel
            s = convertHyphenStr(s: score.ghostScore)
            sr = makeScoreRateStr(scoreRate: score.ghostScoreRate)
            cl = score.ghostClearLump
            pm = score.ghostPlusMinus ?? ""
            mc = score.ghostMissCount
            detailScore = DetailScore(djName: dn, djLevel: dl, score: s, scoreRate: sr, clearLump: cl, plusMinus: pm, missCount: mc)
            scoreArray.append(detailScore)
        }

        // ライバル
        let rivals: Results<RivalStatus> = scoreRealm.objects(RivalStatus.self)
            .filter("\(RivalStatus.Types.playStyle.rawValue) = %@", myUD.getPlayStyle())
        for rival in rivals {
            let rivalScores: Results<RivalScore> = scoreRealm.objects(RivalScore.self)
                .filter("\(RivalScore.Types.iidxId.rawValue) = %@ and \(RivalScore.Types.title.rawValue) = %@ and \(RivalScore.Types.difficultyId.rawValue) = %@ and \(RivalScore.Types.level.rawValue) = %@ and \(RivalScore.Types.playStyle.rawValue) = %@"
                    , rival.iidxId!, score.title!, score.difficultyId, score.level, myUD.getPlayStyle())
            if !rivalScores.isEmpty {
                let rivalScore: RivalScore = rivalScores.first ?? RivalScore()
                dn = rival.djName ?? ""
                dl = rivalScore.djLevel
                s = convertHyphenStr(s: rivalScore.score)
                sr = makeScoreRateStr(scoreRate: rivalScore.scoreRate)
                cl = rivalScore.clearLump
                pm = rivalScore.plusMinus ?? ""
                mc = rivalScore.missCount
                detailScore = DetailScore(djName: dn, djLevel: dl, score: s, scoreRate: sr, clearLump: cl, plusMinus: pm, missCount: mc)
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
        
        // ****************
        // 次のページ
        dispNextPage(seedRealm: seedRealm)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    /*
     セルの数を返す
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return scoreArray.count
    }
    
    /*
     セルを返す
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Log.debugStart(cls: String(describing: self), method: #function)
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! DetailTableViewCell

        let detailScore: DetailScore = scoreArray[indexPath.row]
        cell.djNameLbl.text = detailScore.djName
        
        // ミスカウント
        var miss: String = ""
        if detailScore.missCount == 9999 {
            miss = Const.Label.Score.HYPHEN
        } else {
            miss = String(detailScore.missCount)
        }
        cell.missCntLbl.text = miss
        
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
        
        // プラス・マイナス
        cell.plusMinusLbl.text = detailScore.plusMinus
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return cell
    }
    
    /*
     セルタップ時
     */
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

    /*
     タッチイベント
     */
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
    
    /*
     Closeボタン押下
     */
    @IBAction func tapCloseBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
     上にスワイプ
     */
    @IBAction func swipeUp(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }

    /**
     右にスワイプ
     */
    @IBAction func swipeRight(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        // nextViewを非表示
        nextView.isHidden = true
        // nextボタンの文言変更
        nextBtn.setTitle("Next ▶", for: .normal)
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     左にスワイプ
     */
    @IBAction func swipeLeft(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        // nextViewを表示
        nextView.isHidden = false
        // nextボタンの文言変更
        nextBtn.setTitle("◀ Prev", for: .normal)
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    /**
     次へボタンタップ
     */
    @IBAction func tapNextBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        if nextView.isHidden {
            // nextViewを表示
            nextView.isHidden = false
            // nextボタンの文言変更
            nextBtn.setTitle("◀ Prev", for: .normal)
        } else {
            // nextViewを非表示
            nextView.isHidden = true
            // nextボタンの文言変更
            nextBtn.setTitle("Next ▶", for: .normal)
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     未使用
     */
    @IBAction func tapSp1pBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        openTexTage(playSide: "1")
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     未使用
     */
    @IBAction func tapSp2pBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        openTexTage(playSide: "2")
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     未使用
     */
    @IBAction func tapDpBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        openTexTage(playSide: "D")
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     ブラウザ起動してTexTageを開く
     */
    private func openTexTage(playSide: String) {
        var urlStr = Const.Url().getTexTageUrl()
        urlStr = urlStr + score.title! + ".html?"
        
        var difficulty = ""
        var level = ""

        switch score.difficultyId {
        case 1:
            difficulty = "P"
        case 2:
            difficulty = "N"
        case 3:
            difficulty = "H"
        case 4:
            difficulty = "A"
        case 5:
            difficulty = "X"
        default:
            print("処理なし")
        }
        
        switch score.level {
        case 10:
            level = "A"
        case 11:
            level = "B"
        case 12:
            level = "C"
        default:
            level = String(score.level)
        }
        
        urlStr = urlStr + playSide + difficulty + level + "00"
        
        // ブラウザ起動
        let url = URL(string: urlStr)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options:[:], completionHandler:nil)
        }
    }
    
    /*
     スコアが0の場合は"-"に変換する
     */
    private func convertHyphenStr(s: Int) -> String {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret: String = ""
        if s == 0 {
            ret = Const.Label.Score.HYPHEN
        } else {
            ret = s.description
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
    
    /*
     スコアレート文字列作成
     */
    private func makeScoreRateStr(scoreRate: Double) -> String {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret: String = ""
        if scoreRate != 0 {
            ret = "(\(String(format: "%.2f", scoreRate))%)"
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
    
    /**
     次のページの表示内容設定
     */
    private func dispNextPage(seedRealm: Realm) {
        // 曲データ詳細
        var bpm = ""
        var totalNotes = ""
        var cn = ""
        if let song = seedRealm.objects(Song.self).filter("\(Song.Types.title.rawValue) = %@", score.title!).first {
            // BPM
            // 難易度毎にBPMが異なる場合はCSVより取得
            if song.bpm == "※" {
                // CSVファイル読み込み
                let lines = CommonMethod.loadCSV(filename: Const.Csv.BPM)
                for line in lines {
                    let array = line.components(separatedBy: Const.Csv.SEPARATER)
                    if array[0] == song.title {
                        // SP
                        if myUD.getPlayStyle() == Const.Value.PlayStyle.SINGLE {
                            switch score.difficultyId {
                            case Const.Value.Difficulty.BEGINNER:
                                bpm = array[1]
                            case Const.Value.Difficulty.NORMAL:
                                bpm = array[2]
                            case Const.Value.Difficulty.HYPER:
                                bpm = array[3]
                            case Const.Value.Difficulty.ANOTHER:
                                bpm = array[4]
                            case Const.Value.Difficulty.LEGGENDARIA:
                                bpm = array[5]
                            default:
                                print("処理なし")
                            }
                        // DP
                        } else {
                            switch score.difficultyId {
                            case Const.Value.Difficulty.NORMAL:
                                bpm = array[6]
                            case Const.Value.Difficulty.HYPER:
                                bpm = array[7]
                            case Const.Value.Difficulty.ANOTHER:
                                bpm = array[8]
                            case Const.Value.Difficulty.LEGGENDARIA:
                                bpm = array[9]
                            default:
                                print("処理なし")
                            }
                        }
                    }
                }
            } else {
                bpm = song.bpm ?? ""
            }
            
            // 総ノーツ数、CN
            // SP
            if myUD.getPlayStyle() == Const.Value.PlayStyle.SINGLE {
                switch score.difficultyId {
                case Const.Value.Difficulty.BEGINNER:
                    totalNotes = String(song.totalNotesSpb)
                    cn = song.cnSpb ?? ""
                case Const.Value.Difficulty.NORMAL:
                    totalNotes = String(song.totalNotesSpn)
                    cn = song.cnSpn ?? ""
                case Const.Value.Difficulty.HYPER:
                    totalNotes = String(song.totalNotesSph)
                    cn = song.cnSph ?? ""
                case Const.Value.Difficulty.ANOTHER:
                    totalNotes = String(song.totalNotesSpa)
                    cn = song.cnSpa ?? ""
                case Const.Value.Difficulty.LEGGENDARIA:
                    totalNotes = String(song.totalNotesSpl)
                    cn = song.cnSpl ?? ""
                default:
                    print("処理なし")
                }
            // DP
            } else {
                switch score.difficultyId {
                case Const.Value.Difficulty.NORMAL:
                    totalNotes = String(song.totalNotesDpn)
                    cn = song.cnDpn ?? ""
                case Const.Value.Difficulty.HYPER:
                    totalNotes = String(song.totalNotesDph)
                    cn = song.cnDph ?? ""
                case Const.Value.Difficulty.ANOTHER:
                    totalNotes = String(song.totalNotesDpa)
                    cn = song.cnDpa ?? ""
                case Const.Value.Difficulty.LEGGENDARIA:
                    totalNotes = String(song.totalNotesDpl)
                    cn = song.cnDpl ?? ""
                default:
                    print("処理なし")
                }
            }
        }
        bpmLbl.text = bpm
        totalNotesLbl.text = totalNotes
        if cn != "" {
            cnLbl.text = cn
        } else {
            cnLbl.text = "なし"
        }
        
        // スコアデータ詳細
        // クリアランプ
        var clearLump = ""
        switch score.clearLump {
        case Const.Value.ClearLump.NOPLAY:
            clearLump = Const.Label.ClearLumpDetail.NOPLAY
        case Const.Value.ClearLump.FAILED:
            clearLump = Const.Label.ClearLumpDetail.FAILED
        case Const.Value.ClearLump.ACLEAR:
            clearLump = Const.Label.ClearLumpDetail.AEASY
        case Const.Value.ClearLump.ECLEAR:
            clearLump = Const.Label.ClearLumpDetail.EASY
        case Const.Value.ClearLump.CLEAR:
            clearLump = Const.Label.ClearLumpDetail.CLEAR
        case Const.Value.ClearLump.HCLEAR:
            clearLump = Const.Label.ClearLumpDetail.HARD
        case Const.Value.ClearLump.EXHCLEAR:
            clearLump = Const.Label.ClearLumpDetail.EXHARD
        case Const.Value.ClearLump.FCOMBO:
            clearLump = Const.Label.ClearLumpDetail.FCOMBO
        default:
            print("処理なし")
        }
        clearLampLbl.text = clearLump

        // DJレベル
        var djLevel = ""
        switch score.djLevel {
        case Const.Value.DjLevel.F:
            djLevel = Const.Label.djLevel.F
        case Const.Value.DjLevel.E:
            djLevel = Const.Label.djLevel.E
        case Const.Value.DjLevel.D:
            djLevel = Const.Label.djLevel.D
        case Const.Value.DjLevel.C:
            djLevel = Const.Label.djLevel.C
        case Const.Value.DjLevel.B:
            djLevel = Const.Label.djLevel.B
        case Const.Value.DjLevel.C:
            djLevel = Const.Label.djLevel.C
        case Const.Value.DjLevel.B:
            djLevel = Const.Label.djLevel.B
        case Const.Value.DjLevel.A:
            djLevel = Const.Label.djLevel.A
        case Const.Value.DjLevel.AA:
            djLevel = Const.Label.djLevel.AA
        case Const.Value.DjLevel.AAA:
            djLevel = Const.Label.djLevel.AAA
        default:
            print("処理なし")
        }
        if djLevel != "" {
            djLevel = djLevel + " (" + (score.plusMinus ?? "") + ")"
        } else {
            djLevel = ""
        }
        djLevelLbl.text = djLevel
        
        // スコア（レート）
        if score.score != 0 {
            scoreLbl.text = String(score.score) + " " + makeScoreRateStr(scoreRate: score.scoreRate)
        } else {
            scoreLbl.text = ""
        }
        // PGREATE
        if score.pgreat != 0 {
            pgreateLbl.text = String(score.pgreat)
        } else {
            pgreateLbl.text = ""
        }
        // GREATE
        if score.great != 0 {
            greateLbl.text = String(score.great)
        } else {
            greateLbl.text = ""
        }
        // ミスカウント
        if score.missCount != 9999 {
            missLbl.text = String(score.missCount)
        } else {
            missLbl.text = ""
        }
        // 選曲回数
        playCntLbl.text = String(score.selectCount) + " 回"
        // 最終プレー日時
        if score.lastPlayDate != "" {
            lastPalyDateLbl.text = score.lastPlayDate
        } else {
            lastPalyDateLbl.text = ""
        }
    }
}
