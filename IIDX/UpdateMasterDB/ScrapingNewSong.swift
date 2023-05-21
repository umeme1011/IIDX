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
    
    /*
     新曲ページをスクレイピング
     */
    func scrapingNewSong(newSongDoc: HTMLDocument) {
        Log.debugStart(cls: String(describing: self), method: #function)
            
        let seedRealm: Realm = CommonMethod.createSeedRealm()
        // インデックス取得
        let indexes: Results<Code> = seedRealm.objects(Code.self)
            .filter("\(Code.Types.kindCode.rawValue) = %@", Const.Value.kindCode.INDEX)
        
        var revivalFlg: Bool = false
        
        // versionId
        let versionStr: String = newSongDoc.css("h2")[0].text ?? ""
        let versionId: Int = getVersionForLeggendaria(str: versionStr)
        
        // song
        for node1 in newSongDoc.css("table.style_table")[0].css("tbody")[0].css("tr") {
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
            var ret = getLevelAndCn(str: node1.css("td")[0].text ?? "")
            song.spb = ret.level
            song.cnSpb = ret.cn
            ret = getLevelAndCn(str: node1.css("td")[1].text ?? "")
            song.spn = ret.level
            song.cnSpn = ret.cn
            ret = getLevelAndCn(str: node1.css("td")[2].text ?? "")
            song.sph = ret.level
            song.cnSph = ret.cn
            ret = getLevelAndCn(str: node1.css("td")[3].text ?? "")
            song.spa = ret.level
            song.cnSpa = ret.cn
            ret = getLevelAndCn(str: node1.css("td")[4].text ?? "")
            song.spl = ret.level
            song.cnSpl = ret.cn
            ret = getLevelAndCn(str: node1.css("td")[5].text ?? "")
            song.dpn = ret.level
            song.cnDpn = ret.cn
            ret = getLevelAndCn(str: node1.css("td")[6].text ?? "")
            song.dph = ret.level
            song.cnDph = ret.cn
            ret = getLevelAndCn(str: node1.css("td")[7].text ?? "")
            song.dpa = ret.level
            song.cnDpa = ret.cn
            ret = getLevelAndCn(str: node1.css("td")[8].text ?? "")
            song.dpl = ret.level
            song.cnDpl = ret.cn
            song.bpm = node1.css("td")[9].text ?? ""
            song.genre = node1.css("td")[10].text ?? ""
            
            song.title = node1.css("td")[11].text ?? ""
            
            // タイトルに注釈リンクありで正常に取り込めなかったため個別対応
            if (song.title!.contains("サヨナラ・ヘヴン-Celtic Chip Dance Mix-")) {
                song.title = "サヨナラ・ヘヴン-Celtic Chip Dance Mix-"
            }
            
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
        makeNewNotesDic(newSongDoc: newSongDoc)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}
