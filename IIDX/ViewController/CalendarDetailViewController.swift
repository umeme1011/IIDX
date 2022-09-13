//
//  CalendarDetailViewController.swift
//  IIDX
//
//  Created by umeme on 2022/09/08.
//  Copyright © 2022 umeme. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class CalendarDetailViewController: UIViewController {
    
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var difficultyLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    
    @IBOutlet weak var clearLampLbl: UILabel!
    @IBOutlet weak var djLevelLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var scoreRateLbl: UILabel!
    @IBOutlet weak var pgreateLbl: UILabel!
    @IBOutlet weak var greateLbl: UILabel!
    @IBOutlet weak var missLbl: UILabel!
    
    @IBOutlet weak var updateClearLampLbl: UILabel!
    @IBOutlet weak var updateDjLevelLbl: UILabel!
    @IBOutlet weak var updateScoreLbl: UILabel!
    @IBOutlet weak var diffScoreLbl: UILabel!
    @IBOutlet weak var updateScoreRateLbl: UILabel!
    @IBOutlet weak var diffScoreRateLbl: UILabel!
    @IBOutlet weak var updatePgreateLbl: UILabel!
    @IBOutlet weak var diffPgreateLbl: UILabel!
    @IBOutlet weak var updateGreateLbl: UILabel!
    @IBOutlet weak var diffGreateLbl: UILabel!
    @IBOutlet weak var updateMissLbl: UILabel!
    @IBOutlet weak var diffMissLbl: UILabel!
    
    @IBOutlet weak var upClearLampLbl: UILabel!
    @IBOutlet weak var upDjLevelLbl: UILabel!
    @IBOutlet weak var upScoreLbl: UILabel!
    @IBOutlet weak var upScoreRateLbl: UILabel!
    @IBOutlet weak var upPgreateLbl: UILabel!
    @IBOutlet weak var upGreateLbl: UILabel!
    @IBOutlet weak var upMissLbl: UILabel!
    
    @IBOutlet weak var spaceScoreTitleLbl: UILabel!
    @IBOutlet weak var spaceScoreLbl: UILabel!
    @IBOutlet weak var spaceScoreUpLbl: UILabel!
    @IBOutlet weak var spaceSRTitleLbl: UILabel!
    @IBOutlet weak var spaceSRLbl: UILabel!
    @IBOutlet weak var spaceSRUpLbl: UILabel!
    @IBOutlet weak var spacePGTitleLbl: UILabel!
    @IBOutlet weak var spacePGLbl: UILabel!
    @IBOutlet weak var spacePGUpLbl: UILabel!
    @IBOutlet weak var spaceGTitleLbl: UILabel!
    @IBOutlet weak var spaceGLbl: UILabel!
    @IBOutlet weak var spaceGUpLbl: UILabel!
    @IBOutlet weak var spaceMissTitleLbl: UILabel!
    @IBOutlet weak var spaceMissLbl: UILabel!
    @IBOutlet weak var spaceMissUpLbl: UILabel!
    
    
    var score: OldScore!
    let myUD: MyUserDefaults = MyUserDefaults()

    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        let seedRealm: Realm = CommonMethod.createSeedRealm()
        
        // 曲情報
        setSongData(seedRealm: seedRealm)
        // スコア情報（旧）
        setScore()
        // スコア情報（新）
        setUpdateScore()
        // スコア情報（差分、UPアイコン）
        setDiffScore()
    }
    
    private func setSongData(seedRealm: Realm) {
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
    }
    
    private func setScore() {
        // クリアランプ
        clearLampLbl.text = CommonMethod.getClearLampStr(cd: score.clearLump)
        // DJレベル
        var djLevel = CommonMethod.getDjLevelStr(cd: score.djLevel)
        if djLevel != "" {
            djLevel = djLevel + " (" + (score.plusMinus ?? "") + ")"
        } else {
            djLevel = "-"
        }
        djLevelLbl.text = djLevel
        // スコア
        if score.score != 0 {
            scoreLbl.text = String(score.score)
        } else {
            scoreLbl.text = "-"
        }
        // レート
        if score.scoreRate != 0 {
            scoreRateLbl.text = "\(String(format: "%.2f", score.scoreRate))%"
        } else {
            scoreRateLbl.text = "-"
        }
        // PGREATE
        if score.pgreat != 0 {
            pgreateLbl.text = String(score.pgreat)
        } else {
            pgreateLbl.text = "-"
        }
        // GREATE
        if score.great != 0 {
            greateLbl.text = String(score.great)
        } else {
            greateLbl.text = "-"
        }
        // ミスカウント
        if score.missCount != 9999 {
            missLbl.text = String(score.missCount)
        } else {
            missLbl.text = "-"
        }
    }
    
    private func setUpdateScore() {
        // クリアランプ
        updateClearLampLbl.text = CommonMethod.getClearLampStr(cd: score.updateClearLump)
        // DJレベル
        var djLevel = CommonMethod.getDjLevelStr(cd: score.updateDjLevel)
        if djLevel != "" {
            djLevel = djLevel + " (" + (score.updatePlusMinus ?? "") + ")"
        } else {
            djLevel = "-"
        }
        updateDjLevelLbl.text = djLevel
        // スコア
        if score.updateScore != 0 {
            updateScoreLbl.text = String(score.updateScore)
        } else {
            updateScoreLbl.text = "-"
        }
        // レート
        if score.updateScoreRate != 0 {
            updateScoreRateLbl.text = "\(String(format: "%.2f", score.updateScoreRate))%"
        } else {
            updateScoreRateLbl.text = "-"
        }
        // PGREATE
        if score.updatePgreat != 0 {
            updatePgreateLbl.text = String(score.updatePgreat)
        } else {
            updatePgreateLbl.text = "-"
        }
        // GREATE
        if score.updateGreat != 0 {
            updateGreateLbl.text = String(score.updateGreat)
        } else {
            updateGreateLbl.text = "-"
        }
        // ミスカウント
        if score.updateMissCount != 9999 {
            updateMissLbl.text = String(score.updateMissCount)
        } else {
            updateMissLbl.text = "-"
        }
    }
    
    private func setDiffScore() {
        // クリアランプ
        if score.updateClearLump > score.clearLump {
            upClearLampLbl.textColor = .white
            upClearLampLbl.backgroundColor = .systemRed
            updateClearLampLbl.textColor = .systemRed
        }
        // DJレベル
        if score.updateDjLevel > score.djLevel {
            upDjLevelLbl.textColor = .white
            upDjLevelLbl.backgroundColor = .systemRed
            updateDjLevelLbl.textColor = .systemRed
        }
        // スコア
        var diff = score.updateScore - score.score
        if diff < 0 {
            diffScoreLbl.text = "(\(diff))"
        } else if diff == 0 {
            diffScoreLbl.isHidden = true
            spaceScoreTitleLbl.isHidden = true
            spaceScoreLbl.isHidden = true
            spaceScoreUpLbl.isHidden = true
        } else {
            diffScoreLbl.text = "(+\(diff))"
            upScoreLbl.textColor = .white
            upScoreLbl.backgroundColor = .systemRed
            updateScoreLbl.textColor = .systemRed
            diffScoreLbl.textColor = .systemRed
        }
        // スコアレート
        let diffD = score.updateScoreRate - score.scoreRate
        if diffD < 0 {
            diffScoreRateLbl.text = "(\(String(format: "%.2f", diffD))%)"
        } else if diffD == 0 {
            diffScoreRateLbl.isHidden = true
            spaceSRTitleLbl.isHidden = true
            spaceSRLbl.isHidden = true
            spaceSRUpLbl.isHidden = true
        } else {
            diffScoreRateLbl.text = "(+\(String(format: "%.2f", diffD))%)"
            upScoreRateLbl.textColor = .white
            upScoreRateLbl.backgroundColor = .systemRed
            updateScoreRateLbl.textColor = .systemRed
            diffScoreRateLbl.textColor = .systemRed
        }
        // PGREATE
        diff = score.updatePgreat - score.pgreat
        if diff < 0 {
            diffPgreateLbl.text = "(\(diff))"
        } else if diff == 0 {
            diffPgreateLbl.isHidden = true
            spacePGTitleLbl.isHidden = true
            spacePGLbl.isHidden = true
            spacePGUpLbl.isHidden = true
        } else {
            diffPgreateLbl.text = "(+\(diff))"
            updatePgreateLbl.textColor = .systemRed
            upPgreateLbl.textColor = .white
            upPgreateLbl.backgroundColor = .systemRed
            diffPgreateLbl.textColor = .systemRed
        }
        // GREATE
        diff = score.updateGreat - score.great
        if diff < 0 {
            diffGreateLbl.text = "(\(diff))"
        } else if diff == 0 {
            diffGreateLbl.isHidden = true
            spaceGTitleLbl.isHidden = true
            spaceGLbl.isHidden = true
            spaceGUpLbl.isHidden = true
        } else {
            diffGreateLbl.text = "(+\(diff))"
            updateGreateLbl.textColor = .systemRed
            upGreateLbl.textColor = .white
            upGreateLbl.backgroundColor = .systemRed
            diffGreateLbl.textColor = .systemRed
        }
        // ミスカウント
        var missCnt = 0
        if score.missCount != 9999 {
            missCnt = score.missCount
        }
        diff = score.updateMissCount - missCnt
        if diff < 0 {
            diffMissLbl.text = "(\(diff))"
            upMissLbl.textColor = .white
            upMissLbl.backgroundColor = .systemRed
            updateMissLbl.textColor = .systemRed
            diffMissLbl.textColor = .systemRed
        } else if diff == 0 || score.updateMissCount == 9999 {
            diffMissLbl.isHidden = true
            spaceMissTitleLbl.isHidden = true
            spaceMissLbl.isHidden = true
            spaceMissUpLbl.isHidden = true
        } else {
            diffMissLbl.text = "(+\(diff))"
            if score.missCount == 9999 {
                upMissLbl.textColor = .white
                upMissLbl.backgroundColor = .systemRed
                updateMissLbl.textColor = .systemRed
                diffMissLbl.textColor = .systemRed
            }
        }
    }
    
    @IBAction func tapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     タッチイベント
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                self.dismiss(animated: true, completion: nil)
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}
