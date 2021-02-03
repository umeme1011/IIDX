//
//  Scraping.swift
//  IIDX
//
//  Created by umeme on 2020/09/16.
//  Copyright © 2020 umeme. All rights reserved.
//

import Kanna
import RealmSwift

extension UpdateMasterDB {
    
    /*
     旧曲ページをスクレイピング
     */
    func scrapingOldSong(oldSongDoc: HTMLDocument, oldNotesDoc: HTMLDocument) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        var versionId: Int = 0
        let seedRealm: Realm = CommonMethod.createSeedRealm()
        
        // バージョン取得
        let versions: Results<Code> = seedRealm.objects(Code.self)
            .filter("\(Code.Types.kindCode.rawValue) = %@", Const.Value.kindCode.VERSION)
        // インデックス取得
        let indexes: Results<Code> = seedRealm.objects(Code.self)
            .filter("\(Code.Types.kindCode.rawValue) = %@", Const.Value.kindCode.INDEX)
        
        for node1 in oldSongDoc.css("table.style_table")[1].css("tbody")[0].css("tr") {
            var song: Song = Song()
            
            // get version
            var nextflg: Bool = false
            for node2 in node1.css("a") {
                if (node2["href"] ?? "") == "#BPM" {
                    break
                }
                if (node2.text) == "参照" {
                    break
                }
                versionId = getVersion(str: node2["id"] ?? "", versions: versions)
                if versionId != 0 {
                    nextflg = true
                    break
                }
            }
            
            // goto next <tr>
            if nextflg {
                continue
            }
            let text: String = node1.css("td")[0].text ?? ""
            if text == "SP" {
                continue
            }
            let html: String = node1.css("td")[0].toHTML ?? ""
            if html.contains("colspan=\"13\"") {
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
        
        // set notes
        makeOldNotesDic(oldNotesDoc: oldNotesDoc)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    func correctTitle(str: String) -> String{
        var s: String = str
        if let range = s.range(of: "♡♡") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: "♥♥") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: "♥") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: "♡") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: "ƒƒƒƒƒ") {
            s.replaceSubrange(range, with: "fffff")
        }
        if let range = s.range(of: "never…") {
            s.replaceSubrange(range, with: "never...")
        }
        return s
    }
    
    
    func getVersion(str: String, versions: Results<Code>) -> Int {
        var ret: Int = 0
        if str.isEmpty { return ret }
        
        for ver in versions {
            // バージョンコード０埋め
            let v: String = String(format: "%02d", ver.code)
            if str.contains(v) {
                ret = Int(v) ?? 0
            }
            if str.contains("SS") {
                ret = 1
            }
        }
        return ret
    }
    
    
    func convertStringToInt(str: String) -> Int {
        var ret = 0
        if str.isEmpty { return ret }
        
        var s = str
        if let range = s.range(of: "[CN]") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: "[CN?]") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: "[BSS]") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: "[BSS?]") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: "[HCN]") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: "[HCN?]") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: "[HBSS]") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: "[HBSS?]") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: "(") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: ")") {
            s.replaceSubrange(range, with: "")
        }

        if s == "-" || s == "×" || s == "?" {
            ret = 0
        } else {
            ret = Int(s) ?? 0
        }
        return ret
    }
    
    func getLevelAndCn(str: String) -> (level: Int, cn: String) {
        var level = 0
        var cn = ""
        if str.isEmpty { return (level, cn) }
        
        var s = str
        if let range = s.range(of: "[CN]") {
            s.replaceSubrange(range, with: "")
            cn = cn + "[CN]"
        }
        if let range = s.range(of: "[CN?]") {
            s.replaceSubrange(range, with: "")
            cn = cn + "[CN]"
        }
        if let range = s.range(of: "[BSS]") {
            s.replaceSubrange(range, with: "")
            cn = cn + "[BSS]"
        }
        if let range = s.range(of: "[BSS?]") {
            s.replaceSubrange(range, with: "")
            cn = cn + "[BSS]"
        }
        if let range = s.range(of: "[HCN]") {
            s.replaceSubrange(range, with: "")
            cn = cn + "[HCN]"
        }
        if let range = s.range(of: "[HCN?]") {
            s.replaceSubrange(range, with: "")
            cn = cn + "[HCN]"
        }
        if let range = s.range(of: "[HBSS]") {
            s.replaceSubrange(range, with: "")
            cn = cn + "[HBSS]"
        }
        if let range = s.range(of: "[HBSS?]") {
            s.replaceSubrange(range, with: "")
            cn = cn + "[HBSS]"
        }
        if let range = s.range(of: "(") {
            s.replaceSubrange(range, with: "")
        }
        if let range = s.range(of: ")") {
            s.replaceSubrange(range, with: "")
        }

        if s == "-" || s == "×" || s == "?" {
            level = 0
        } else {
            level = Int(s) ?? 0
        }
        return (level, cn)
    }

    func getIndexId(str: String, indexes: Results<Code>) -> Int {
        var ret = 0
        if str.isEmpty { return ret }
        
        for index in indexes {
            if index.code == 7 { continue }
            if index.name!.contains(str.prefix(1).uppercased()) {
                ret = index.code
                break
            } else {
                ret = 7
            }
        }
        return ret
    }
    
    
    func arrangeSong(song: Song) -> Song {
        
        if song.title == "CODE:1 [revision1.0.1]" {
            return song
        }
        
        if song.title == "Friction[!]Function" {
            return song
        }
        
        if song.genre?.contains("[") ?? false {
            song.genre = song.genre?.components(separatedBy: "[")[0]
        }
        if song.title?.contains("[") ?? false {
            song.title = song.title?.components(separatedBy: "[")[0]
        }
        if song.artist?.contains("[") ?? false {
            song.artist = song.artist?.components(separatedBy: "[")[0]
        }
        return song
    }
    
    
    func getVersionForLeggendaria(str: String) -> Int {
        var ret: Int = 0
        
        let startIndex = str.index(str.startIndex, offsetBy: 15) // 開始位置 15
        let endIndex = str.index(startIndex, offsetBy: 2) // 長さ 2
        var s = str[startIndex..<endIndex]
        
        if let range = s.range(of: "t") {
            s.replaceSubrange(range, with: "")
        }
        
        ret = Int(s) ?? 0
        return ret
    }
}
