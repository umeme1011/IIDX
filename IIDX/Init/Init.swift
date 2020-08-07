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
    
    static func doInit() {
        copyRealmFile()
        initMyScore()
    }
    
    /// シードデータRealmファイルをコピー
    static private func copyRealmFile() {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        let fileManager: FileManager = FileManager()
        let mainBundle = Bundle.main
        let seedRealmPath: String = CommonMethod.getSeedRealmPath()
        
        // DBパス表示
        Log.info(cls: String(describing: self), method: #function, msg: seedRealmPath)
        
        // 毎回既存ファイルを削除
        if fileManager.fileExists(atPath: seedRealmPath) {
            do {
                try FileManager.default.removeItem(atPath: seedRealmPath)
            } catch {
                Log.error(cls: String(describing: self), method: #function, msg: Const.Log.INIT_001)
            }
        }
        // コピー
        let atPath = mainBundle.path(forResource: Const.Realm.SEED_FILE_NAME, ofType: "realm")
        try! FileManager().copyItem(atPath: atPath!, toPath: seedRealmPath)
        _ = Realm.Configuration(fileURL: URL(fileURLWithPath: seedRealmPath), readOnly: true)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// MyScoreテーブルにSongテーブルのデータを登録
    /// 新曲追加時（iidx_seed.realm更新時）は差分登録を行う
    static private func initMyScore() {
        
        let seedRealm: MyRealm = MyRealm.init(path: CommonMethod.getSeedRealmPath())
        let scoreRealm: MyRealm = MyRealm.init(path: CommonMethod.getScoreRealmPath())
        
        var scores: Results<MyScore> = scoreRealm.readAll(MyScore.self)
            .sorted(byKeyPath: MyScore.Types.createDate.rawValue, ascending: false)
        var songs: Results<Song> = seedRealm.readAll(Song.self)
            .sorted(byKeyPath: Song.Types.createDate.rawValue, ascending: false)
        
        var id: Int = 1
        
        // scores TBL が空の場合は全曲登録
        if !scores.isEmpty {
        
            // 差分登録
            if (scores.first!.createDate < songs.first!.createDate){
                
                // 未取り込みのsongを取得
                songs = seedRealm.readAllByCreateDate(Song.self, param: scores.first!.createDate)
                
                // MyScoreのidを取得
                scores = scoreRealm.readAll(MyScore.self)
                    .sorted(byKeyPath: MyScore.Types.id.rawValue, ascending: false)
                id = scores.first!.id + 1
                
                print(songs)
                print(id)
            
            // 差分がない場合は何もしない
            } else {
                return
            }
        }
        
        var myScoreArray: [MyScore] = [MyScore]()
        
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
                scoreSpb.createDate = song.createDate
                myScoreArray.append(scoreSpb)
                id += 1
            }
            if song.spn != 0 {
                scoreSpn.id = id
                scoreSpn.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSpn.difficultyId = Const.Value.Difficulty.NORMAL
                scoreSpn.level = song.spn
                scoreSpn.totalNotes = song.totalNotesSpn
                scoreSpn = setScoreCommon(score: scoreSpn, song: song)
                scoreSpn.createDate = song.createDate
                myScoreArray.append(scoreSpn)
                id += 1
            }
            if song.sph != 0 {
                scoreSph.id = id
                scoreSph.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSph.difficultyId = Const.Value.Difficulty.HYPER
                scoreSph.level = song.sph
                scoreSph.totalNotes = song.totalNotesSph
                scoreSph = setScoreCommon(score: scoreSph, song: song)
                scoreSph.createDate = song.createDate
                myScoreArray.append(scoreSph)
                id += 1
            }
            if song.spa != 0 {
                scoreSpa.id = id
                scoreSpa.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSpa.difficultyId = Const.Value.Difficulty.ANOTHER
                scoreSpa.level = song.spa
                scoreSpa.totalNotes = song.totalNotesSpa
                scoreSpa = setScoreCommon(score: scoreSpa, song: song)
                scoreSpa.createDate = song.createDate
                myScoreArray.append(scoreSpa)
                id += 1
            }
            if song.spl != 0 {
                scoreSpl.id = id
                scoreSpl.playStyle = Const.Value.PlayStyle.SINGLE
                scoreSpl.difficultyId = Const.Value.Difficulty.LEGGENDARIA
                scoreSpl.level = song.spl
                scoreSpl.totalNotes = song.totalNotesSpl
                scoreSpl = setScoreCommon(score: scoreSpl, song: song)
                scoreSpl.createDate = song.createDate
                myScoreArray.append(scoreSpl)
                id += 1
            }
            if song.dpn != 0 {
                scoreDpn.id = id
                scoreDpn.playStyle = Const.Value.PlayStyle.DOUBLE
                scoreDpn.difficultyId = Const.Value.Difficulty.NORMAL
                scoreDpn.level = song.dpn
                scoreDpn.totalNotes = song.totalNotesDpn
                scoreDpn = setScoreCommon(score: scoreDpn, song: song)
                scoreDpn.createDate = song.createDate
                myScoreArray.append(scoreDpn)
                id += 1
            }
            if song.dph != 0 {
                scoreDph.id = id
                scoreDph.playStyle = Const.Value.PlayStyle.DOUBLE
                scoreDph.difficultyId = Const.Value.Difficulty.HYPER
                scoreDph.level = song.dph
                scoreDph.totalNotes = song.totalNotesDph
                scoreDph = setScoreCommon(score: scoreDph, song: song)
                scoreDph.createDate = song.createDate
                myScoreArray.append(scoreDph)
                id += 1
            }
            if song.dpa != 0 {
                scoreDpa.id = id
                scoreDpa.playStyle = Const.Value.PlayStyle.DOUBLE
                scoreDpa.difficultyId = Const.Value.Difficulty.ANOTHER
                scoreDpa.level = song.dpa
                scoreDpa.totalNotes = song.totalNotesDpa
                scoreDpa = setScoreCommon(score: scoreDpa, song: song)
                scoreDpa.createDate = song.createDate
                myScoreArray.append(scoreDpa)
                id += 1
            }
            if song.dpl != 0 {
                scoreDpl.id = id
                scoreDpl.playStyle = Const.Value.PlayStyle.DOUBLE
                scoreDpl.difficultyId = Const.Value.Difficulty.LEGGENDARIA
                scoreDpl.level = song.dpl
                scoreDpl.totalNotes = song.totalNotesDpl
                scoreDpl = setScoreCommon(score: scoreDpl, song: song)
                scoreDpl.createDate = song.createDate
                myScoreArray.append(scoreDpl)
                id += 1
            }
        }
        
        // save db
        for score in myScoreArray {
            scoreRealm.create(data: [score])
        }
    }
    
    static private func setScoreCommon(score: MyScore, song: Song) -> MyScore {
        score.title = song.title
        score.genre = song.genre
        score.artist = song.artist
        score.versionId = song.versionId
        score.indexId = song.indexId
        return score
    }
}
