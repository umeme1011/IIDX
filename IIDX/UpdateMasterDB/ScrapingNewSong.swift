//
//  ScrapingNewSong.swift
//  IIDX
//
//  Created by umeme on 2020/09/16.
//  Copyright © 2020 umeme. All rights reserved.
//

import Kanna
import RealmSwift

extension UpdateMasterDB {
    
    func scrapingNewSong(html: String) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // Scraping
        if let doc = try? HTML(html: html, encoding: .utf8) {
            
            // 最終更新日時が同じ場合は取得しない
            wikiNewSongLastModified = doc.css("div#lastmodified").first?.text ?? ""
            wikiNewSongLastModified = wikiNewSongLastModified.trimmingCharacters(in: .whitespaces)
            if wikiNewSongLastModified == myUD.getWikiNewSongLastModified() {
                return
            }
            
            let seedRealm: Realm = CommonMethod.createSeedRealm()
            // インデックス取得
            let indexes: Results<Code> = seedRealm.objects(Code.self)
                .filter("\(Code.Types.kindCode.rawValue) = %@", Const.Value.kindCode.INDEX)
            
            var revivalFlg: Bool = false
            
            // versionId
            let versionStr: String = doc.css("h2")[0].text ?? ""
            let versionId: Int = getVersionForLeggendaria(str: versionStr)
            
            // song
            for node1 in doc.css("table.style_table")[0].css("tbody")[0].css("tr") {
                var song: Song = Song()
                
                // goto next <tr>
                let html: String = node1.css("td")[0].toHTML ?? ""
                if html.contains("colspan=\"13\"") {
                    if node1.css("td")[0].text == "復活曲" {
                        revivalFlg = true
                    } else {
                        revivalFlg = false
                    }
                    continue
                }
                
                // guard duplicate
                if revivalFlg {
                    continue
                }
                
                // set song model
                song.id = songId
                song.spb = convertStringToInt(str: node1.css("td")[0].text ?? "")
                song.spn = convertStringToInt(str: node1.css("td")[1].text ?? "")
                song.sph = convertStringToInt(str: node1.css("td")[2].text ?? "")
                song.spa = convertStringToInt(str: node1.css("td")[3].text ?? "")
                song.spl = convertStringToInt(str: node1.css("td")[4].text ?? "")
                song.dpn = convertStringToInt(str: node1.css("td")[5].text ?? "")
                song.dph = convertStringToInt(str: node1.css("td")[6].text ?? "")
                song.dpa = convertStringToInt(str: node1.css("td")[7].text ?? "")
                song.dpl = convertStringToInt(str: node1.css("td")[8].text ?? "")
                song.bpm = node1.css("td")[9].text ?? ""
                song.genre = node1.css("td")[10].text ?? ""
                song.title = node1.css("td")[11].text ?? ""
                song.artist = node1.css("td")[12].text ?? ""
                song.versionId = versionId
                song.indexId = getIndexId(str: song.title ?? "", indexes: indexes)
                
                // どの難易度にもデータがない場合は取得しない
                if song.spb == 0 && song.spn == 0 && song.sph == 0 && song.spa == 0 && song.spl == 0
                    && song.dpn == 0 && song.dph == 0 && song.dpa == 0 && song.dpl == 0 {
                    continue
                }

                song = arrangeSong(song: song)
                
                songId += 1
                
//                print(song)
                songArray.append(song)
            }
            
            // notes
            makeNewNotesDic(html: html)
        }
        updFlg = true
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}
