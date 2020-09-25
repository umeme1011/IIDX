//
//  SaveMasterDB.swift
//  IIDX
//
//  Created by umeme on 2020/09/16.
//  Copyright © 2020 umeme. All rights reserved.
//

import RealmSwift

extension UpdateMasterDB {
    
    /*
     DB登録
     */
    func saveMasterDB() {
        Log.debugStart(cls: String(describing: self), method: #function)

        let seedRealm: Realm = CommonMethod.createSeedRealm()
        
        // 保存パス出力
        print(seedRealm.configuration.fileURL!)
        
        // 登録
        try! seedRealm.write {
            // Song全件取得
            let songs: Results<Song> = seedRealm.objects(Song.self)

            // MyScore差分登録
            msg = Init.init().updateMyScore(newSongs: songArray, oldSongs: songs)
            
            // UserDefaults更新
            myUD.setWikiOldSongLastModified(date: wikiOldSongLastModified)
            myUD.setWikiOldNotesLastModified(date: wikiOldNotesLastModified)
            myUD.setWikiNewSongLastModified(date: wikiNewSongLastModified)

            if msg == "マスタDBの更新はありませんでした。" {
                updFlg = false
                return
            }

            // 全件削除
            seedRealm.delete(songs)

            // Song登録
            for song in songArray {
                seedRealm.add(song)
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}
