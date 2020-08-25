//
//  SaveDB.swift
//  IIDX
//
//  Created by umeme on 2019/08/30.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

extension Import {
    
    func saveDB(target: String, seedRealm: MyRealm, scoreRealm: MyRealm) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if isCancel(msg: "saveDB") { return }

        // 進捗
        DispatchQueue.main.async {
            self.mainVC.progressLbl.text = Const.Label.SAVING
        }
        
        // マイステータス
        scoreRealm.deleteAll(MyStatus.self)
        scoreRealm.create(data: myStatuses)

        // ライバルリスト
        scoreRealm.deleteAll(RivalStatus.self)
        scoreRealm.create(data: rivals)
        
        // マイスコア
        saveMyScore(seedRealm: seedRealm, scoreRealm: scoreRealm)
        
        // ライバルスコア
        saveRivalScore(target: target, seedRealm: seedRealm, scoreRealm: scoreRealm)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// マイスコア登録
    private func saveMyScore(seedRealm: MyRealm, scoreRealm: MyRealm) {
        Log.debugStart(cls: String(describing: self), method: #function)

        if myScoreArray.isEmpty {
            return
        }
        
        let now: Date = Date()
        
        // LastImportDateTBL更新
        self.saveLastImportDate(realm: scoreRealm)
        // LastImportDate ID取得
        let lastImportDate: LastImportDate = scoreRealm.readAllByPlayStyle(LastImportDate.self)
            .first ?? LastImportDate()
        let lastImportDateId = lastImportDate.id
        
        // OldScoreTBL選択プレイスタイル全件削除
        scoreRealm.deleteAllByPlayStyle(OldScore.self)
        // OldScore ID取得
        var oldScoreId: Int = 1
        if let oldScore: OldScore = scoreRealm.readAll(OldScore.self)
            .sorted(byKeyPath: OldScore.Types.id.rawValue, ascending: false).first {
            oldScoreId = oldScore.id + 1
        }
        
        // 取込曲数分ループ
        var cnt: Int = 0
        for score in myScoreArray {
            
            if score.title == "Χ-DEN" {
                print("TEST")
            }
            
            // 進捗
            DispatchQueue.main.async {
                self.mainVC.progressLbl.text = "\(Const.Label.SAVING)  \(cnt)/\(self.myScoreArray.count)"
            }
            cnt += 1
            
            // 曲名の表記ゆれを修正　wikiに合わせる
            score.title = getFixTitle(title: score.title ?? "")
            
            if let result: MyScore
                = scoreRealm.readEqualAndByPlayStyle(MyScore.self
                    , ofTypes: [MyScore.Types.title.rawValue, MyScore.Types.difficultyId.rawValue]
                    , forQuery: [[score.title] as AnyObject, [score.difficultyId] as AnyObject]).first {
                
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
                score.createDate = result.createDate
                score.createUser = result.createUser
                score.updateDate = now
                score.updateUser = Const.Realm.SYSTEM
                
                // スコア更新あり（初回取り込み時はスルー）
                if ((score.clearLump != result.clearLump)
                    || (score.djLevel != result.djLevel)
                    || (score.score != result.score))
                    //                    || (score.missCount != result.missCount)      // ミスカウント取り込み変更で拾ってしまうのでなしで・・
                    && !firstLoadFlg
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
                    oldScore.scoreRate = result.scoreRate
                    oldScore.missCount = result.missCount
                    oldScore.createDate = now
                    oldScore.createUser = Const.Realm.SYSTEM
                    oldScore.createDate = now
                    oldScore.updateUser = Const.Realm.SYSTEM
                    scoreRealm.create(data: [oldScore])
                    oldScoreId += 1
                }
                // 更新
                scoreRealm.update(data: [score])
            } else {
                print("表記ゆれ")
                print(score.title)
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    
    /// ライバルスコア登録
    private func saveRivalScore(target: String, seedRealm: MyRealm, scoreRealm: MyRealm) {
        Log.debugStart(cls: String(describing: self), method: #function)

        if rivalScoreArray.isEmpty {
            return
        }
        
        // 対象アカウントスコアデータ全件削除
        scoreRealm.deleteEqualAndByPlayStyle(RivalScore.self
            , ofTypes: [RivalScore.Types.iidxId.rawValue], forQuery: [[target] as AnyObject])
        
        let now: Date = Date()
        var cnt: Int = 0
        // 取込曲数分ループ
        for score in rivalScoreArray {
            
            // 曲名の表記ゆれを修正　wikiに合わせる
            score.title = getFixTitle(title: score.title ?? "")

            // 進捗
            DispatchQueue.main.async {
                self.mainVC.progressLbl.text = "\(Const.Label.SAVING)  \(cnt)/\(self.rivalScoreArray.count)"
            }
            cnt += 1
            
            // 曲基本情報取得
            if let song: Song = seedRealm.readEqual(Song.self
                , ofTypes: Song.Types.title.rawValue, forQuery: [score.title] as AnyObject).first {
            
                // 曲基本情報をScore TBLにセット
                score.playStyle = playStyle
                score.versionId = song.versionId
                score.indexId = song.indexId
                
                // レベル、スコアレート
                if playStyle == Const.Value.PlayStyle.DOUBLE {
                    if score.difficultyId == Const.Value.Difficulty.NORMAL {
                        score.level = song.dpn
                        score.scoreRate = calcurateScoreRate(score: score.score ?? "", totalNotes: song.totalNotesDpn)
                    } else if score.difficultyId == Const.Value.Difficulty.HYPER {
                        score.level = song.dph
                        score.scoreRate = calcurateScoreRate(score: score.score ?? "", totalNotes: song.totalNotesDph)
                    } else if score.difficultyId == Const.Value.Difficulty.ANOTHER {
                        score.level = song.dpa
                        score.scoreRate = calcurateScoreRate(score: score.score ?? "", totalNotes: song.totalNotesDpa)
                    }
                } else {
                    if score.difficultyId == Const.Value.Difficulty.NORMAL {
                        score.level = song.spn
                        score.scoreRate = calcurateScoreRate(score: score.score ?? "", totalNotes: song.totalNotesSpn)
                    } else if score.difficultyId == Const.Value.Difficulty.HYPER {
                        score.level = song.sph
                        score.scoreRate = calcurateScoreRate(score: score.score ?? "", totalNotes: song.totalNotesSph)
                    } else if score.difficultyId == Const.Value.Difficulty.ANOTHER {
                        score.level = song.spa
                        score.scoreRate = calcurateScoreRate(score: score.score ?? "", totalNotes: song.totalNotesSpa)
                    }
                }
                // 存在しない難易度は登録しない
                if score.level == 0 {
                    continue
                }
                
                // 新規登録
                let s: RivalScore = scoreRealm.readAll(RivalScore.self)
                    .sorted(byKeyPath: RivalScore.Types.id.rawValue, ascending: false).first ?? RivalScore()
                
                score.id = s.id + 1
                score.createDate = now
                score.createUser = Const.Realm.SYSTEM
                score.updateDate = now
                score.updateUser = Const.Realm.SYSTEM
                scoreRealm.create(data: [score])
            } else {
                print("表記ゆれ")
                print(score.title)
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// 最終取込日更新
    private func saveLastImportDate(realm: MyRealm) {
        Log.debugStart(cls: String(describing: self), method: #function)

        // 現在日時整形
        let now: Date = Date()
        let dateFormater: DateFormatter = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd"
        let date: String = dateFormater.string(from: now)
        
        // プレイスタイルより最終取込日データ取得
        let lid: LastImportDate = LastImportDate()
        if let lastImportDate: LastImportDate
            = realm.readAllByPlayStyle(LastImportDate.self).first {
            
            // 更新
            lid.id = lastImportDate.id
            lid.playStyle = lastImportDate.playStyle
            lid.date = date
            lid.createDate = lastImportDate.createDate
            lid.createUser = lastImportDate.createUser
            lid.updateDate = now
            lid.updateUser = Const.Realm.SYSTEM
            realm.update(data: [lid])
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
            realm.create(data: [lid])
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// スコアレート計算
    private func calcurateScoreRate(score: String, totalNotes: Int) -> Double {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret = 0.0
        
        if score.isEmpty {
            return ret
        }
        if totalNotes == 0 {
            return ret
        }
        
        let scoreDouble: Double = Double(score.components(separatedBy: "(")[0]) ?? 0.0
        let theoreticalValue: Double = Double(totalNotes * 2)
        if theoreticalValue != 0 {
            ret = (scoreDouble / theoreticalValue) * 100.0
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
    
    
    /// タイトルの表記ゆれを修正
    private func getFixTitle(title: String) -> String {
        var ret: String = title
        
        // タイトルの表記ゆれを修正　wikiに合わせる
        let titles: [String] = CommonMethod.loadCSV(filename: Const.Csv.FILE_NAME)
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
}
