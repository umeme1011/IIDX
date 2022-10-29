//
//  ScrapingNotes.swift
//  IIDX
//
//  Created by umeme on 2020/09/16.
//  Copyright © 2020 umeme. All rights reserved.
//

import Kanna

extension UpdateMasterDB {
    
    /*
     旧曲ノーツページをスクレイピング
     */
    func makeOldNotesDic(oldNotesDoc: HTMLDocument) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        for node1 in oldNotesDoc.css("table.style_table")[1].css("tbody")[0].css("tr") {
            
            // goto next <tr>
            let html: String = node1.css("td")[0].toHTML ?? ""
            if html.contains("colspan=\"13\"") {
                continue
            }
            
            let title: String = node1.css("td")[0].text ?? ""
            var notesArray: [Int] = [Int]()
            notesArray.append(convertStringToInt(str: node1.css("td")[1].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[2].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[3].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[4].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[5].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[6].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[7].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[8].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[9].text ?? ""))

//                print(notesArray)
            notesDic[title] = notesArray
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
        
    /*
     新曲ノーツ部分をスクレイピング
     */
    func makeNewNotesDic(newSongDoc: HTMLDocument) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        let myUD: MyUserDefaults = MyUserDefaults.init()
        var num = 1
        if myUD.getVersion() == 29 {
            num = 2
        }
        
        // 2022.8.11 テーブルが一つ増えてたけど、またなくなってもとに戻す
        for node1 in newSongDoc.css("table.style_table")[num].css("tbody")[0].css("tr") {
            
            // goto next <tr>
            let html: String = node1.css("td")[0].toHTML ?? ""
            if html.contains("colspan=\"13\"") {
                continue
            }
            
            let title: String = node1.css("td")[0].text ?? ""
            var notesArray: [Int] = [Int]()
            notesArray.append(convertStringToInt(str: node1.css("td")[1].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[2].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[3].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[4].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[5].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[6].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[7].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[8].text ?? ""))
            notesArray.append(convertStringToInt(str: node1.css("td")[9].text ?? ""))
            
            notesDic[title] = notesArray
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    /*
     songArrayにノーツをセット
     */
    func setNotes() {
        Log.debugStart(cls: String(describing: self), method: #function)
        
//        // load csv file
//        let noNotesTitleArray: [String] = CommonMethod.loadCSV(filename: Const.Csv.NO_NOTES_TITLE)
        
        var songArrayCopy = songArray
        for song in songArray {
            let t: String = correctTitle(str: song.title ?? "")
//            var isSet: Bool = false
            
            for (k, v) in notesDic {
                let kt: String = correctTitle(str: k)
                if kt == t {
                    song.totalNotesSpb = v[0]
                    song.totalNotesSpn = v[1]
                    song.totalNotesSph = v[2]
                    song.totalNotesSpa = v[3]
                    song.totalNotesSpl = v[4]
                    song.totalNotesDpn = v[5]
                    song.totalNotesDph = v[6]
                    song.totalNotesDpa = v[7]
                    song.totalNotesDpl = v[8]
                    
                    // for no notes title confirm
                    songArrayCopy.remove(value: song)
//                    isSet = true
                }
            }
//            if !isSet {
//                for noNotesTitle in noNotesTitleArray {
//                    let array: [String] = noNotesTitle.components(separatedBy: ",")
//                    let nt: String = correctTitle(str: array[0])
//                    if nt == t {
//                        song.totalNotesSpb = Int(array[1]) ?? 0
//                        song.totalNotesSpn = Int(array[2]) ?? 0
//                        song.totalNotesSph = Int(array[3]) ?? 0
//                        song.totalNotesSpa = Int(array[4]) ?? 0
//                        song.totalNotesSpl = Int(array[5]) ?? 0
//                        song.totalNotesDpn = Int(array[6]) ?? 0
//                        song.totalNotesDph = Int(array[7]) ?? 0
//                        song.totalNotesDpa = Int(array[8]) ?? 0
//                        song.totalNotesDpl = Int(array[9]) ?? 0
//
//                        // for no notes title confirm
//                        songArrayCopy.remove(value: song)
//                    }
//                }
//            }
        }
        // for no notes title confirm
        print("NO NOTES!!",songArrayCopy)
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}
