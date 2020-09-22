//
//  UpdateMasterDB.swift
//  IIDX
//
//  Created by umeme on 2020/09/16.
//  Copyright © 2020 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class UpdateMasterDB {
    
    var songArray: [Song] = [Song]()
    var songId: Int = 1
    var notesDic: [String : [Int]] = [String : [Int]]()
    var codeArray: [Code] = [Code]()
    var updFlg: Bool = false
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
        // HTML取得
        
        // Old Song
        let songHtml: String = getHtmlStr(url: Const.Url().getWikiOldSongUrl())
        let notesHtml: String = getHtmlStr(url: Const.Url().getWikiOldNotesListUrl())
        scrapingOldSong(songHtml: songHtml, notesHtml: notesHtml)
        
        // New Song
        let newHtml: String = getHtmlStr(url: Const.Url().getWikiNewSongListUrl())
        scrapingNewSong(html: newHtml)

        if !updFlg {
            msg = "更新はありませんでした。"
            return
        }

        // Notes
        setNotes()
        
        // DB登録
        saveMasterDB()
    }
    
    private func getHtmlStr(url: String) -> String {
        let data: NSData = CommonMethod.getRequest(dataUrl: url)
        let dataStr: String = String(data: data as Data, encoding: .japaneseEUC) ?? ""
        return dataStr
    }
}
