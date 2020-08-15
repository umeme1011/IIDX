//
//  Init.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class Init {
    
    static func doInit() -> String {
        
        copyRealmFile()
        return initMyScore()
    }
    
    /// シードデータRealmファイルをコピー
    static private func copyRealmFile() {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        let fileManager: FileManager = FileManager()
        let mainBundle = Bundle.main
        let seedRealmPath: String = CommonMethod.getSeedRealmPath()
        
        // DBパス表示
        Log.info(cls: String(describing: self), method: #function, msg: seedRealmPath)
        
        // 最新VerのSeedファイル存在確認しない
        if !fileManager.fileExists(atPath: seedRealmPath) {
            
            // Document内のファイル名一覧を取得
            let documentDir: NSString
            = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            do {
                let fileNames = try fileManager.contentsOfDirectory(atPath: documentDir as String)
                // 最新Ver以外のSeedファイルを削除
                for name in fileNames {
                    if name.contains("iidx_seed") {
                        try FileManager.default.removeItem(atPath: documentDir.appendingPathComponent(name))
                    }
                }
            } catch {
                Log.error(cls: String(describing: self), method: #function, msg: Const.Log.INIT_001)
            }
            
            // コピー
            let atPath = mainBundle.path(forResource: Const.Realm.SEED_FILE_NAME, ofType: "realm")
            try! FileManager().copyItem(atPath: atPath!, toPath: seedRealmPath)
            _ = Realm.Configuration(fileURL: URL(fileURLWithPath: seedRealmPath), readOnly: true)
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// MyScoreテーブルにSongテーブルのデータを登録
    /// 新曲追加時（iidx_seed.realm更新時）は差分更新を行う
    static private func initMyScore() -> String {

        let seedRealm: MyRealm = MyRealm.init(path: CommonMethod.getSeedRealmPath())
        let scoreRealm: MyRealm = MyRealm.init(path: CommonMethod.getScoreRealmPath())

        var scores: Results<MyScore> = scoreRealm.readAll(MyScore.self)
            .sorted(byKeyPath: MyScore.Types.updateDate.rawValue, ascending: false)
        var songs: Results<Song> = seedRealm.readAll(Song.self)
            .sorted(byKeyPath: Song.Types.updateDate.rawValue, ascending: false)

        var id: Int = 1
        var ret = ""

        // scores TBL が空でない場合は差分更新
        if !scores.isEmpty {
            
            // 更新フラグが1のsongを取得
            songs = seedRealm.readEqual(Song.self, ofTypes: Song.Types.updFlg.rawValue, forQuery: [1] as AnyObject)

            print("更新あり")
            print(songs)
            
            // 差分あり
            if (!songs.isEmpty){
                
                // MyScoreのmaxid+1を取得
                scores = scoreRealm.readAll(MyScore.self).sorted(byKeyPath: MyScore.Types.id.rawValue, ascending: false)
                id = scores.first!.id + 1
        
                // 更新用配列作成
                let scoreArray: [MyScore] = makeUpdateScoreArray(songs: songs, nextId: id, scoreRealm: scoreRealm)
                
                // MyScore更新（idが同じ場合は更新）
                for score in scoreArray {
                    scoreRealm.update(data: [score])
                }
                
                // アラートメッセージ
                var msg: String = Const.Message.SEED_DB_UPDATE_COMPLETE
                msg += "\n\nVer\(Const.Realm.SEED_DB_VER) 更新曲："
                for song in songs {
                    msg += ("\n" + song.title!)
                }
                ret = msg
                
            // 差分がない場合は何もしない
            } else {
                return ret
            }
            
        // 初回時全部取り込み
        } else {
        
            // 登録用配列作成
            let scoreArray: [MyScore] = makeInsertScoreArray(songs: songs, nextId: id)

            // save db
            for score in scoreArray {
                scoreRealm.create(data: [score])
            }
            
            // アラートメッセージ
            ret = Const.Message.SEED_DB_IMPORT_COMPLETE
        }
        
        // Songの更新フラグを0にする
        for song in songs {
            seedRealm.updateUpdFlg(song: song, updFlg: 0)
        }
        
        return ret
    }
    
    /// 登録用配列作成
    static private func makeInsertScoreArray(songs: Results<Song>, nextId: Int) -> [MyScore] {
        var ret: [MyScore] = [MyScore]()
        var id: Int = nextId
        
        for song in songs {
            var scoreSpb: MyScore = MyScore()
            var scoreSpn: MyScore = MyScore()
            var scoreSph: MyScore = MyScore()
            var scoreSpa: MyScore = MyScore()
            var scoreSpl: MyScore = MyScore()
            var scoreDpn: MyScore = MyScore()
            var scoreDph: MyScore = MyScore()
            var scoreDpa: MyScore = MyScore()
            var scoreDpl: MyScore = MyScore()

            if song.spb != 0 {
                scoreSpb.id = id
                scoreSpb.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSpb.difficultyId = Const.Value.Difficulty.BEGINNER
                scoreSpb.level = song.spb
                scoreSpb.totalNotes = song.totalNotesSpb
                scoreSpb = setScoreCommon(score: scoreSpb, song: song)
                ret.append(scoreSpb)
                id += 1
            }
            if song.spn != 0 {
                scoreSpn.id = id
                scoreSpn.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSpn.difficultyId = Const.Value.Difficulty.NORMAL
                scoreSpn.level = song.spn
                scoreSpn.totalNotes = song.totalNotesSpn
                scoreSpn = setScoreCommon(score: scoreSpn, song: song)
                ret.append(scoreSpn)
                id += 1
            }
            if song.sph != 0 {
                scoreSph.id = id
                scoreSph.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSph.difficultyId = Const.Value.Difficulty.HYPER
                scoreSph.level = song.sph
                scoreSph.totalNotes = song.totalNotesSph
                scoreSph = setScoreCommon(score: scoreSph, song: song)
                ret.append(scoreSph)
                id += 1
            }
            if song.spa != 0 {
                scoreSpa.id = id
                scoreSpa.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSpa.difficultyId = Const.Value.Difficulty.ANOTHER
                scoreSpa.level = song.spa
                scoreSpa.totalNotes = song.totalNotesSpa
                scoreSpa = setScoreCommon(score: scoreSpa, song: song)
                ret.append(scoreSpa)
                id += 1
            }
            if song.spl != 0 {
                scoreSpl.id = id
                scoreSpl.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSpl.difficultyId = Const.Value.Difficulty.LEGGENDARIA
                scoreSpl.level = song.spl
                scoreSpl.totalNotes = song.totalNotesSpl
                scoreSpl = setScoreCommon(score: scoreSpl, song: song)
                ret.append(scoreSpl)
                id += 1
            }
            if song.dpn != 0 {
                scoreDpn.id = id
                scoreDpn.playStyle = Const.Value.PlayStyle.DOUBLE
                scoreDpn.difficultyId = Const.Value.Difficulty.NORMAL
                scoreDpn.level = song.dpn
                scoreDpn.totalNotes = song.totalNotesDpn
                scoreDpn = setScoreCommon(score: scoreDpn, song: song)
                ret.append(scoreDpn)
                id += 1
            }
            if song.dph != 0 {
                scoreDph.id = id
                scoreDph.playStyle = Const.Value.PlayStyle.DOUBLE
                scoreDph.difficultyId = Const.Value.Difficulty.HYPER
                scoreDph.level = song.dph
                scoreDph.totalNotes = song.totalNotesDph
                scoreDph = setScoreCommon(score: scoreDph, song: song)
                ret.append(scoreDph)
                id += 1
            }
            if song.dpa != 0 {
                scoreDpa.id = id
                scoreDpa.playStyle = Const.Value.PlayStyle.DOUBLE
                scoreDpa.difficultyId = Const.Value.Difficulty.ANOTHER
                scoreDpa.level = song.dpa
                scoreDpa.totalNotes = song.totalNotesDpa
                scoreDpa = setScoreCommon(score: scoreDpa, song: song)
                ret.append(scoreDpa)
                id += 1
            }
            if song.dpl != 0 {
                scoreDpl.id = id
                scoreDpl.playStyle = Const.Value.PlayStyle.DOUBLE
                scoreDpl.difficultyId = Const.Value.Difficulty.LEGGENDARIA
                scoreDpl.level = song.dpl
                scoreDpl.totalNotes = song.totalNotesDpl
                scoreDpl = setScoreCommon(score: scoreDpl, song: song)
                ret.append(scoreDpl)
                id += 1
            }
        }
        return ret
    }

    /*
     更新用配列作成
     MyScoreを検索し、存在する場合はMyScoreのidを設定、存在しない場合はmax idを設定します
     scoreArray:更新用配列
     */
    static private func makeUpdateScoreArray(songs: Results<Song>, nextId: Int, scoreRealm: MyRealm)
        -> [MyScore] {
            
        var ret: [MyScore] = [MyScore]()
        var id: Int = nextId
        
        for song in songs {
            var scoreSpb: MyScore = MyScore()
            var scoreSpn: MyScore = MyScore()
            var scoreSph: MyScore = MyScore()
            var scoreSpa: MyScore = MyScore()
            var scoreSpl: MyScore = MyScore()
            var scoreDpn: MyScore = MyScore()
            var scoreDph: MyScore = MyScore()
            var scoreDpa: MyScore = MyScore()
            var scoreDpl: MyScore = MyScore()

            if song.spb != 0 {
                // タイトルと難易度とプレイスタイルでScoreを検索
                let scores: Results<MyScore> = scoreRealm.readEqualAnd(MyScore.self
                    , ofTypes: [MyScore.Types.title.rawValue, MyScore.Types.difficultyId.rawValue, MyScore.Types.playStyle.rawValue]
                    , forQuery: [[song.title!] as AnyObject, [Const.Value.Difficulty.BEGINNER] as AnyObject, [Const.Value.PlayStyle.SINGLE] as AnyObject])
                if !scores.isEmpty {
                    scoreSpb = setScoreCommonForUpdate(scoreTo: scoreSpb, scoreFrom: scores.first!)
                } else {
                    scoreSpb.id = id
                    id += 1
                }
                scoreSpb.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSpb.difficultyId = Const.Value.Difficulty.BEGINNER
                scoreSpb.level = song.spb
                scoreSpb.totalNotes = song.totalNotesSpb
                scoreSpb = setScoreCommon(score: scoreSpb, song: song)
                ret.append(scoreSpb)
            }
            if song.spn != 0 {
                // タイトルと難易度とプレイスタイルでScoreを検索
                let scores: Results<MyScore> = scoreRealm.readEqualAnd(MyScore.self
                    , ofTypes: [MyScore.Types.title.rawValue, MyScore.Types.difficultyId.rawValue, MyScore.Types.playStyle.rawValue]
                    , forQuery: [[song.title!] as AnyObject, [Const.Value.Difficulty.NORMAL] as AnyObject, [Const.Value.PlayStyle.SINGLE] as AnyObject])
                if !scores.isEmpty {
                    scoreSpn = setScoreCommonForUpdate(scoreTo: scoreSpn, scoreFrom: scores.first!)
                } else {
                    scoreSpn.id = id
                    id += 1
                }
                scoreSpn.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSpn.difficultyId = Const.Value.Difficulty.NORMAL
                scoreSpn.level = song.spn
                scoreSpn.totalNotes = song.totalNotesSpn
                scoreSpn = setScoreCommon(score: scoreSpn, song: song)
                ret.append(scoreSpn)
            }
            if song.sph != 0 {
                // タイトルと難易度とプレイスタイルでScoreを検索
                let scores: Results<MyScore> = scoreRealm.readEqualAnd(MyScore.self
                    , ofTypes: [MyScore.Types.title.rawValue, MyScore.Types.difficultyId.rawValue, MyScore.Types.playStyle.rawValue]
                    , forQuery: [[song.title!] as AnyObject, [Const.Value.Difficulty.HYPER] as AnyObject, [Const.Value.PlayStyle.SINGLE] as AnyObject])
                if !scores.isEmpty {
                    scoreSph = setScoreCommonForUpdate(scoreTo: scoreSph, scoreFrom: scores.first!)
                } else {
                    scoreSph.id = id
                    id += 1
                }
                scoreSph.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSph.difficultyId = Const.Value.Difficulty.HYPER
                scoreSph.level = song.sph
                scoreSph.totalNotes = song.totalNotesSph
                scoreSph = setScoreCommon(score: scoreSph, song: song)
                ret.append(scoreSph)
            }
            if song.spa != 0 {
                // タイトルと難易度とプレイスタイルでScoreを検索
                let scores: Results<MyScore> = scoreRealm.readEqualAnd(MyScore.self
                    , ofTypes: [MyScore.Types.title.rawValue, MyScore.Types.difficultyId.rawValue, MyScore.Types.playStyle.rawValue]
                    , forQuery: [[song.title!] as AnyObject, [Const.Value.Difficulty.ANOTHER] as AnyObject, [Const.Value.PlayStyle.SINGLE] as AnyObject])
                if !scores.isEmpty {
                    scoreSpa = setScoreCommonForUpdate(scoreTo: scoreSpa, scoreFrom: scores.first!)
                } else {
                    scoreSpa.id = id
                    id += 1
                }
                scoreSpa.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSpa.difficultyId = Const.Value.Difficulty.ANOTHER
                scoreSpa.level = song.spa
                scoreSpa.totalNotes = song.totalNotesSpa
                scoreSpa = setScoreCommon(score: scoreSpa, song: song)
                ret.append(scoreSpa)
            }
            if song.spl != 0 {
                // タイトルと難易度とプレイスタイルでScoreを検索
                let scores: Results<MyScore> = scoreRealm.readEqualAnd(MyScore.self
                    , ofTypes: [MyScore.Types.title.rawValue, MyScore.Types.difficultyId.rawValue, MyScore.Types.playStyle.rawValue]
                    , forQuery: [[song.title!] as AnyObject, [Const.Value.Difficulty.LEGGENDARIA] as AnyObject, [Const.Value.PlayStyle.SINGLE] as AnyObject])
                if !scores.isEmpty {
                    scoreSpl = setScoreCommonForUpdate(scoreTo: scoreSpl, scoreFrom: scores.first!)
                } else {
                    scoreSpl.id = id
                    id += 1
                }
                scoreSpl.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSpl.difficultyId = Const.Value.Difficulty.LEGGENDARIA
                scoreSpl.level = song.spl
                scoreSpl.totalNotes = song.totalNotesSpl
                scoreSpl = setScoreCommon(score: scoreSpl, song: song)
                ret.append(scoreSpl)
            }
            if song.dpn != 0 {
                // タイトルと難易度とプレイスタイルでScoreを検索
                let scores: Results<MyScore> = scoreRealm.readEqualAnd(MyScore.self
                    , ofTypes: [MyScore.Types.title.rawValue, MyScore.Types.difficultyId.rawValue, MyScore.Types.playStyle.rawValue]
                    , forQuery: [[song.title!] as AnyObject, [Const.Value.Difficulty.NORMAL] as AnyObject, [Const.Value.PlayStyle.DOUBLE] as AnyObject])
                if !scores.isEmpty {
                    scoreDpn = setScoreCommonForUpdate(scoreTo: scoreDpn, scoreFrom: scores.first!)
                } else {
                    scoreDpn.id = id
                    id += 1
                }
                scoreDpn.playStyle = Const.Value.PlayStyle.DOUBLE
                scoreDpn.difficultyId = Const.Value.Difficulty.NORMAL
                scoreDpn.level = song.dpn
                scoreDpn.totalNotes = song.totalNotesDpn
                scoreDpn = setScoreCommon(score: scoreDpn, song: song)
                ret.append(scoreDpn)
            }
            if song.dph != 0 {
                // タイトルと難易度とプレイスタイルでScoreを検索
                let scores: Results<MyScore> = scoreRealm.readEqualAnd(MyScore.self
                    , ofTypes: [MyScore.Types.title.rawValue, MyScore.Types.difficultyId.rawValue, MyScore.Types.playStyle.rawValue]
                    , forQuery: [[song.title!] as AnyObject, [Const.Value.Difficulty.HYPER] as AnyObject, [Const.Value.PlayStyle.DOUBLE] as AnyObject])
                if !scores.isEmpty {
                    scoreDph = setScoreCommonForUpdate(scoreTo: scoreDph, scoreFrom: scores.first!)
                } else {
                    scoreDph.id = id
                    id += 1
                }
                scoreDph.playStyle = Const.Value.PlayStyle.DOUBLE
                scoreDph.difficultyId = Const.Value.Difficulty.HYPER
                scoreDph.level = song.dph
                scoreDph.totalNotes = song.totalNotesDph
                scoreDph = setScoreCommon(score: scoreDph, song: song)
                ret.append(scoreDph)
            }
            if song.dpa != 0 {
                // タイトルと難易度とプレイスタイルでScoreを検索
                let scores: Results<MyScore> = scoreRealm.readEqualAnd(MyScore.self
                    , ofTypes: [MyScore.Types.title.rawValue, MyScore.Types.difficultyId.rawValue, MyScore.Types.playStyle.rawValue]
                    , forQuery: [[song.title!] as AnyObject, [Const.Value.Difficulty.ANOTHER] as AnyObject, [Const.Value.PlayStyle.DOUBLE] as AnyObject])
                if !scores.isEmpty {
                    scoreDpa = setScoreCommonForUpdate(scoreTo: scoreDpa, scoreFrom: scores.first!)
                } else {
                    scoreDpa.id = id
                    id += 1
                }
                scoreDpa.playStyle = Const.Value.PlayStyle.DOUBLE
                scoreDpa.difficultyId = Const.Value.Difficulty.ANOTHER
                scoreDpa.level = song.dpa
                scoreDpa.totalNotes = song.totalNotesDpa
                scoreDpa = setScoreCommon(score: scoreDpa, song: song)
                ret.append(scoreDpa)
            }
            if song.dpl != 0 {
                // タイトルと難易度とプレイスタイルでScoreを検索
                let scores: Results<MyScore> = scoreRealm.readEqualAnd(MyScore.self
                    , ofTypes: [MyScore.Types.title.rawValue, MyScore.Types.difficultyId.rawValue, MyScore.Types.playStyle.rawValue]
                    , forQuery: [[song.title!] as AnyObject, [Const.Value.Difficulty.LEGGENDARIA] as AnyObject, [Const.Value.PlayStyle.DOUBLE] as AnyObject])
                if !scores.isEmpty {
                    scoreDpl = setScoreCommonForUpdate(scoreTo: scoreDpl, scoreFrom: scores.first!)
                } else {
                    scoreDpl.id = id
                    id += 1
                }
                scoreDpl.playStyle = Const.Value.PlayStyle.DOUBLE
                scoreDpl.difficultyId = Const.Value.Difficulty.LEGGENDARIA
                scoreDpl.level = song.dpl
                scoreDpl.totalNotes = song.totalNotesDpl
                scoreDpl = setScoreCommon(score: scoreDpl, song: song)
                ret.append(scoreDpl)
            }
        }
        return ret
    }

    
    ///
    static private func setScoreCommon(score: MyScore, song: Song) -> MyScore {
        score.title = song.title
        score.genre = song.genre
        score.artist = song.artist
        score.versionId = song.versionId
        score.indexId = song.indexId
        score.createDate = song.createDate
        score.updateDate = song.updateDate
        return score
    }
    
    ///
    static private func setScoreCommonForUpdate(scoreTo: MyScore, scoreFrom: MyScore) -> MyScore {
        scoreTo.id = scoreFrom.id
        scoreTo.clearLump = scoreFrom.clearLump
        scoreTo.djLevel = scoreFrom.djLevel
        scoreTo.score = scoreFrom.score
        scoreTo.scoreRate = scoreFrom.scoreRate
        scoreTo.missCount = scoreFrom.missCount
        scoreTo.selectCount = scoreFrom.selectCount
        scoreTo.oldScoreId = scoreFrom.oldScoreId
        scoreTo.tag = scoreFrom.tag
        return scoreTo
    }
}
