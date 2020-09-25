//
//  UpdateMasterDB.swift
//  IIDX
//
//  Created by umeme on 2020/09/16.
//  Copyright © 2020 umeme. All rights reserved.
//

import UIKit
import RealmSwift
import Kanna

class UpdateMasterDB {
    
    var songArray: [Song] = [Song]()
    var songId: Int = 1
    var notesDic: [String : [Int]] = [String : [Int]]()
    var codeArray: [Code] = [Code]()
    var updFlg: Bool = true
    var msg: String = ""
    var wikiOldSongLastModified: String = ""
    var wikiOldNotesLastModified: String = ""
    var wikiNewSongLastModified: String = ""
    var myUD: MyUserDefaults = MyUserDefaults.init()
    
    init() {
    }
    
    /*
     wikiからデータを取り込んでSeedDBへ登録
     */
    func doUpdate() {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // HTML取得
        let oldSongHtml: String = getHtmlStr(url: Const.Url().getWikiOldSongUrl())
        let oldNotesHtml: String = getHtmlStr(url: Const.Url().getWikiOldNotesListUrl())
        let newSongHtml: String = getHtmlStr(url: Const.Url().getWikiNewSongListUrl())

        var oldSongDoc: HTMLDocument!
        var oldNotesDoc: HTMLDocument!
        var newSongDoc: HTMLDocument!
        
        // 最終更新日時チェック
        // wikiの旧曲ページ、旧曲ノーツページ、新曲ページの最終更新日時がすべて同じ場合は取得しない
        if let doc = try? HTML(html: oldSongHtml, encoding: .utf8) {
            oldSongDoc = doc
            wikiOldSongLastModified = doc.css("div#lastmodified").first?.text ?? ""
            wikiOldSongLastModified = wikiOldSongLastModified.trimmingCharacters(in: .whitespaces)
        }
        if let doc = try? HTML(html: oldNotesHtml, encoding: .utf8) {
            oldNotesDoc = doc
            wikiOldNotesLastModified = doc.css("div#lastmodified").first?.text ?? ""
            wikiOldNotesLastModified = wikiOldNotesLastModified.trimmingCharacters(in: .whitespaces)
        }
        if let doc = try? HTML(html: newSongHtml, encoding: .utf8) {
            newSongDoc = doc
            wikiNewSongLastModified = doc.css("div#lastmodified").first?.text ?? ""
            wikiNewSongLastModified = wikiNewSongLastModified.trimmingCharacters(in: .whitespaces)
        }
        if wikiOldSongLastModified == myUD.getWikiOldSongLastModified()
            && wikiOldNotesLastModified == myUD.getWikiOldNotesLastModified()
            && wikiNewSongLastModified == myUD.getWikiNewSongLastModified() {
            updFlg = false
            msg = "マスタDBの更新はありませんでした。"
            return
        }

        // スクレイピング
        scrapingOldSong(oldSongDoc: oldSongDoc, oldNotesDoc: oldNotesDoc)
        scrapingNewSong(newSongDoc: newSongDoc)

        // songArrayにNotesをセット
        setNotes()
        
        // DB登録
        saveMasterDB()
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    private func getHtmlStr(url: String) -> String {
        let data: NSData = CommonMethod.getRequest(dataUrl: url)
        let dataStr: String = String(data: data as Data, encoding: .japaneseEUC) ?? ""
        return dataStr
    }
}
