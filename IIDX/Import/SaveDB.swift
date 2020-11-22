//
//  SaveDB.swift
//  IIDX
//
//  Created by umeme on 2019/08/30.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

extension Import {
    
    func saveDB(target: String, seedRealm: Realm, scoreRealm: Realm) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if isCancel(msg: "saveDB") { return }

        // 進捗
        DispatchQueue.main.async {
            self.mainVC.progressLbl.text = Const.Label.SAVING
        }
        
        // マイステータス
        try! scoreRealm.write {
            // 全件削除
            let obj = scoreRealm.objects(MyStatus.self)
            scoreRealm.delete(obj)
            // 登録
            for s in myStatuses {
                scoreRealm.add(s)
            }
        }

        // ライバルリスト
        try! scoreRealm.write {
            // 全件削除
            let obj = scoreRealm.objects(RivalStatus.self)
            scoreRealm.delete(obj)
            // 登録
            for r in rivals {
                scoreRealm.add(r)
            }
        }
        
        // マイスコア
        saveMyScore(seedRealm: seedRealm, scoreRealm: scoreRealm)
        
        // ライバルスコア
        saveRivalScore(target: target, seedRealm: seedRealm, scoreRealm: scoreRealm)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// マイスコア登録
    private func saveMyScore(seedRealm: Realm, scoreRealm: Realm) {
        Log.debugStart(cls: String(describing: self), method: #function)

        if myScoreArray.isEmpty {
            return
        }
        
        let now: Date = Date()
        
        // LastImportDateTBL更新
        self.saveLastImportDate(realm: scoreRealm)
        // LastImportDate ID取得
        let lastImportDate: LastImportDate = scoreRealm.objects(LastImportDate.self)
            .filter("\(LastImportDate.Types.playStyle.rawValue) = %@", playStyle).first ?? LastImportDate()
        let lastImportDateId = lastImportDate.id
        
        // OldScoreTBL選択プレイスタイル全件削除
        try! scoreRealm.write {
            let obj = scoreRealm.objects(OldScore.self)
            scoreRealm.delete(obj)
        }
        // OldScore ID取得
        var oldScoreId: Int = 1
        if let oldScore: OldScore = scoreRealm.objects(OldScore.self)
            .sorted(byKeyPath: OldScore.Types.id.rawValue, ascending: false).first {
            oldScoreId = oldScore.id + 1
        }
        
        // タイトル表記揺れ吸収用CSV読み込み
        let titles: [String] = CommonMethod.loadCSV(filename: Const.Csv.CORRECT_TITLE)
        
        // 取込曲数分ループ
        var cnt: Int = 0
        try! scoreRealm.write {
            for score in myScoreArray {
                // 進捗
                DispatchQueue.main.async {
                    self.mainVC.progressLbl.text = "\(Const.Label.SAVING)  \(cnt)/\(self.myScoreArray.count)"
                }
                cnt += 1
                
                // 曲名の表記ゆれを修正　wikiに合わせる
                score.title = getFixTitle(titles: titles, title: score.title ?? "")
                
                if let result: MyScore
                    = scoreRealm.objects(MyScore.self).filter("\(MyScore.Types.title.rawValue) = %@ and \(MyScore.Types.difficultyId.rawValue) = %@ and \(MyScore.Types.playStyle.rawValue) = %@", score.title!, score.difficultyId, playStyle).first {

                    score.id = result.id
                    score.playStyle = result.playStyle
                    score.genre = result.genre
                    score.artist = result.artist
                    score.difficultyId = result.difficultyId
                    score.level = result.level
                    score.totalNotes = result.totalNotes
                    score.scoreRate = calcurateScoreRate(score: score.score, totalNotes: result.totalNotes)
                    score.versionId = result.versionId
                    score.indexId = result.indexId
                    score.lastImportDateId = 0
                    score.oldScoreId = 0
                    score.plusMinus = calcuratePlusMinus(score: score.score, totalNotes: result.totalNotes)
                    score.tag = result.tag
                    score.ghostScore = result.ghostScore
                    score.memo = result.memo
                    score.createDate = result.createDate
                    score.createUser = result.createUser
                    score.updateDate = now
                    score.updateUser = Const.Realm.SYSTEM
                    
                    // スコア更新あり（初回取り込み時はスルー）
                    if ((score.clearLump != result.clearLump)
                        || (score.djLevel != result.djLevel)
                        || (score.score != result.score))
                        || (score.missCount != result.missCount)
                        || (score.plusMinus != result.plusMinus)
//                        && !firstLoadFlg
                        && score.clearLump != Const.Value.ClearLump.NOPLAY
                    {
                        score.lastImportDateId = lastImportDateId
                        score.oldScoreId = oldScoreId
                        
                        // oldscoreTBL登録
                        let oldScore: OldScore = OldScore()
                        oldScore.id = oldScoreId
                        oldScore.playStyle = playStyle
                        oldScore.title = result.title
                        oldScore.difficultyId = result.difficultyId
                        oldScore.level = result.level
                        oldScore.clearLump = result.clearLump
                        oldScore.djLevel = result.djLevel
                        oldScore.score = result.score
                        oldScore.pgreat = result.pgreat
                        oldScore.great = result.great
                        oldScore.scoreRate = result.scoreRate
                        oldScore.missCount = result.missCount
                        oldScore.plusMinus = result.plusMinus
                        oldScore.createDate = now
                        oldScore.createUser = Const.Realm.SYSTEM
                        oldScore.createDate = now
                        oldScore.updateUser = Const.Realm.SYSTEM
                        scoreRealm.add(oldScore)
                        oldScoreId += 1
                    }
                    // 更新
                    scoreRealm.add(score, update: .all)
                } else {
                    print("表記ゆれ")
                    print(score.title!)
                }
            }
        }
        
        // 前作ゴーストをコピー
        copyGhostScore()

        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    
    /// ライバルスコア登録
    private func saveRivalScore(target: String, seedRealm: Realm, scoreRealm: Realm) {
        Log.debugStart(cls: String(describing: self), method: #function)

        if rivalScoreArray.isEmpty {
            return
        }
        
        // 対象アカウントスコアデータ全件削除
        try! scoreRealm.write {
            let results = scoreRealm.objects(RivalScore.self).filter("\(RivalScore.Types.iidxId.rawValue) = %@", target)
            scoreRealm.delete(results)
        }

        let now: Date = Date()
        var cnt: Int = 0

        // タイトル表記揺れ吸収用CSV読み込み
        let titles: [String] = CommonMethod.loadCSV(filename: Const.Csv.CORRECT_TITLE)

        try! scoreRealm.write {
            // 取込曲数分ループ
            for score in rivalScoreArray {
                
                // 曲名の表記ゆれを修正　wikiに合わせる
                score.title = getFixTitle(titles: titles, title: score.title ?? "")

                // 進捗
                DispatchQueue.main.async {
                    self.mainVC.progressLbl.text = "\(Const.Label.SAVING)  \(cnt)/\(self.rivalScoreArray.count)"
                }
                cnt += 1
                
                // 曲基本情報取得
                if let song: Song = seedRealm.objects(Song.self).filter("\(Song.Types.title.rawValue) = %@", score.title!).first {

                    // 曲基本情報をScore TBLにセット
                    score.playStyle = playStyle
                    score.versionId = song.versionId
                    score.indexId = song.indexId
                    
                    // レベル、スコアレート
                    if playStyle == Const.Value.PlayStyle.DOUBLE {
                        if score.difficultyId == Const.Value.Difficulty.NORMAL {
                            score.level = song.dpn
                            score.scoreRate = calcurateScoreRate(score: score.score, totalNotes: song.totalNotesDpn)
                            score.plusMinus = calcuratePlusMinus(score: score.score, totalNotes: song.totalNotesDpn)
                        } else if score.difficultyId == Const.Value.Difficulty.HYPER {
                            score.level = song.dph
                            score.scoreRate = calcurateScoreRate(score: score.score, totalNotes: song.totalNotesDph)
                        } else if score.difficultyId == Const.Value.Difficulty.ANOTHER {
                            score.level = song.dpa
                            score.scoreRate = calcurateScoreRate(score: score.score, totalNotes: song.totalNotesDpa)
                        } else if score.difficultyId == Const.Value.Difficulty.LEGGENDARIA {
                            score.level = song.dpl
                            score.scoreRate = calcurateScoreRate(score: score.score, totalNotes: song.totalNotesDpl)
                        }
                    } else {
                        if score.difficultyId == Const.Value.Difficulty.BEGINNER {
                            score.level = song.spb
                            score.scoreRate = calcurateScoreRate(score: score.score, totalNotes: song.totalNotesSpb)
                        } else if score.difficultyId == Const.Value.Difficulty.NORMAL {
                            score.level = song.spn
                            score.scoreRate = calcurateScoreRate(score: score.score, totalNotes: song.totalNotesSpn)
                        } else if score.difficultyId == Const.Value.Difficulty.HYPER {
                            score.level = song.sph
                            score.scoreRate = calcurateScoreRate(score: score.score, totalNotes: song.totalNotesSph)
                            score.plusMinus = calcuratePlusMinus(score: score.score, totalNotes: song.totalNotesSph)
                        } else if score.difficultyId == Const.Value.Difficulty.ANOTHER {
                            score.level = song.spa
                            score.scoreRate = calcurateScoreRate(score: score.score, totalNotes: song.totalNotesSpa)
                        } else if score.difficultyId == Const.Value.Difficulty.LEGGENDARIA {
                            score.level = song.spl
                            score.scoreRate = calcurateScoreRate(score: score.score, totalNotes: song.totalNotesSpl)
                        }
                    }
                    // 存在しない難易度は登録しない
                    if score.level == 0 {
                        continue
                    }
                    
                    // 新規登録
                    let s: RivalScore = scoreRealm.objects(RivalScore.self)
                        .sorted(byKeyPath: RivalScore.Types.id.rawValue, ascending: false).first ?? RivalScore()

                    score.id = s.id + 1
                    score.createDate = now
                    score.createUser = Const.Realm.SYSTEM
                    score.updateDate = now
                    score.updateUser = Const.Realm.SYSTEM
                    
                    // 登録
                    scoreRealm.add(score)
                } else {
                    print("表記ゆれ")
                    print(score.title!)
                }
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// 最終取込日更新
    private func saveLastImportDate(realm: Realm) {
        Log.debugStart(cls: String(describing: self), method: #function)

        // 現在日時整形
        let now: Date = Date()
        let dateFormater: DateFormatter = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd"
        let date: String = dateFormater.string(from: now)
        
        // プレイスタイルより最終取込日データ取得
        let lid: LastImportDate = LastImportDate()
        if let lastImportDate: LastImportDate = realm.objects(LastImportDate.self)
            .filter("\(LastImportDate.Types.playStyle.rawValue) = %@", playStyle).first {
            // 更新
            lid.id = lastImportDate.id
            lid.playStyle = lastImportDate.playStyle
            lid.date = date
            lid.createDate = lastImportDate.createDate
            lid.createUser = lastImportDate.createUser
            lid.updateDate = now
            lid.updateUser = Const.Realm.SYSTEM
            
        } else {
            // 新規登録
            var id = 1
            if playStyle == Const.Value.PlayStyle.DOUBLE {
                id = 2
            }
            lid.id = id
            lid.playStyle = playStyle
            lid.date = date
            lid.createUser = Const.Realm.SYSTEM
            lid.updateUser = Const.Realm.SYSTEM
        }
        
        // 登録更新
        try! realm.write {
            realm.add(lid, update: .all)
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /**
     スコアレート計算
     */
    private func calcurateScoreRate(score: Int, totalNotes: Int) -> Double {
        return CommonMethod.calcurateScoreRate(score: score, totalNotes: totalNotes)
    }
    
    /**
     プラス・マイナス計算
     */
    private func calcuratePlusMinus(score: Int, totalNotes: Int) -> String {
        return CommonMethod.calcuratePlusMinus(score: score, totalNotes: totalNotes)
    }
    
    
    /// タイトルの表記ゆれを修正
    private func getFixTitle(titles: [String], title: String) -> String {
        var ret: String = title
        
        // タイトルの表記ゆれを修正　wikiに合わせる
        var fixFlg: Bool = false
        for title in titles {
            let array: [String] = title.components(separatedBy: Const.Csv.SEPARATER)
            if ret == array[0] {
                ret = array[1]
                fixFlg = true
            }
        }
        if !fixFlg {
            ret = fixTitle(title: ret)
        }
        
        return ret
    }
    
    private func fixTitle(title: String) -> String {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        var ret: String = title
        
        // trim
        ret = ret.trimmingCharacters(in: .whitespaces)
        
        while true {
            if let range:Range = ret.range(of: "～") {
                ret.replaceSubrange(range, with:"〜")
            } else {
                break
            }
        }

        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
    
    /**
     前作ゴーストをコピーする　※１回のみ実行
     */
    private func copyGhostScore() {
        // スキーマバージョン5でMyScoreに前作ゴーストスコアカラムを追加したので
        // １回のみ27→28へスコアのコピーを行う
        if !myUD.getGhostScoreCopyFlg() && myUD.getVersion() != Const.Version.START_VERSION_NO {
            let preScoreRealm = CommonMethod.createPreScoreRealm()
            let scoreRealm = CommonMethod.createScoreRealm()
            // 前作スコアが存在しない＝28になってからインストールして27スコア未取り込み
            // 今作スコアが存在しない＝バージョン切り替えを行っていないor初回起動
            // 上記いずれかの場合は、前作ゴーストカラムコピー処理を行わない
            if !preScoreRealm.isEmpty && !scoreRealm.isEmpty {
                let scores = scoreRealm.objects(MyScore.self)
                try! scoreRealm.write {
                    for new in scores {
                        // 前作スコアが存在する場合はコピーする
                        if let old = preScoreRealm.objects(MyScore.self)
                            .filter("\(MyScore.Types.title.rawValue) == %@", new.title!)
                            .filter("\(MyScore.Types.difficultyId.rawValue) == %@", new.difficultyId)
                            .filter("\(MyScore.Types.playStyle.rawValue) == %@", new.playStyle)
                            .first {
                            new.ghostClearLump = old.clearLump
                            new.ghostDjLevel = old.djLevel
                            new.ghostScore = old.score
                            new.ghostPgreat = old.pgreat
                            new.ghostGreat = old.great
                            new.ghostScoreRate = old.scoreRate
                            new.ghostMissCount = old.missCount
                            new.ghostSelectCount = old.selectCount
                            new.ghostPlusMinus = old.plusMinus
                        }
                    }
                }
                myUD.setGhostScoreCopyFlg(flg: true)
            }
        }
    }

}
