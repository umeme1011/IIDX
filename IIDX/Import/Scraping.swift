//
//  Scraping.swift
//  IIDX
//
//  Created by umeme on 2019/08/29.
//  Copyright © 2019 umeme. All rights reserved.
//

import Kanna

extension Import {
    
    /// マイステータスページHTMLパース
    func parseMyStatus(html: String) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if let doc = try? HTML(html: html, encoding: .utf8) {
            if doc.css("div.dj-profile").count == 0 {
                Log.error(cls: String(describing: self), method: #function, msg: Const.Log.SCRAPING_001)
                stopFlg = true
                return
            }
            
            let myStatus: MyStatus = MyStatus()
            
            // HTMLパース
            for node1 in doc.css("div.qpro-img") {
                let qproUrl: String = node1.css("img")[0]["src"] ?? ""
                // クプロ画像をアプリ内に保存
                let url: String = Const.Url.KONAMI + (qproUrl)
                CommonMethod.saveImage(image: UIImage(url: url), fileName: Const.Image.Qpro.FILE_NAME)
            }
            for node1 in doc.css("div.dj-profile") {
                for node2 in node1.css("tr") {
                    if node2.css("td")[0].text == "DJ NAME" {
                        // DJNAME
                        myStatus.djName = node2.css("td")[1].text
                    }
                    if node2.css("td")[0].text == "IIDX ID" {
                        // IIDX ID
                        myStatus.iidxId = node2.css("td")[1].text
                    }
                }
            }
            
            for node1 in doc.css("div.dj-rank") {
                if node1.css("div")[0].text == "段位認定" {
                    // 段位（SP/DP）
                    myStatus.rank = (node1.css("div")[3].text ?? "") + "/" + (node1.css("div")[6].text ?? "")
                }
            }
            
            let now: Date = Date()
            myStatus.id = 1
            myStatus.createDate = now
            myStatus.createUser = Const.Realm.SYSTEM
            myStatus.updateDate = now
            myStatus.updateUser = Const.Realm.SYSTEM
            
            myStatuses.append(myStatus)
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// ライバルリストページHTMLパース
    func parseRivalList(html: String) {
        Log.debugStart(cls: String(describing: self), method: #function)

        if let doc = try? HTML(html: html, encoding: .utf8) {
            if doc.css("div.rival-list").count == 0 {
                Log.error(cls: String(describing: self), method: #function, msg: Const.Log.SCRAPING_001)
                stopFlg = true
                return
            }
            
            let now: Date = Date()
            var playStyle: Int = 0
            
            var id: Int = 1
            for node1 in doc.css("div.rival-list") {
                
                // プレイスタイル取得
                let playStyleStr: String = node1.css("tr")[0].css("th")[0].text ?? "0"
                if playStyleStr == "DP" {
                    playStyle = Const.Value.PlayStyle.DOUBLE
                } else {
                    playStyle = Const.Value.PlayStyle.SINGLE
                }
                
                var i: Int = 0
                for node2 in node1.css("tr") {
                    if i > 1 {
                        let rival: RivalStatus = RivalStatus()
                        
                        // DjName IIDXID 段位 code 取得
                        rival.playStyle = playStyle
                        
                        for node3 in node2.css("a") {
                            var code: String = node3["href"] ?? ""
                            
                            if code.contains("rival=") {
                                code = code.components(separatedBy: "rival=")[1]
                            } else if code.contains("robo=") {
                                code = code.components(separatedBy: "robo=")[1]
                            }
                            rival.code = code
                            
                            rival.id = id
                            rival.djName = node2.css("a")[0].text!
                            rival.iidxId = node2.css("td")[2].text!
                            rival.rank = node2.css("td")[3].text!
                            rival.createDate = now
                            rival.createUser = Const.Realm.SYSTEM
                            rival.updateDate = now
                            rival.updateUser = Const.Realm.SYSTEM
                            rivals.append(rival)
                            
                            id += 1
                        }
                    }
                    i += 1
                }
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    
    
    /// マイスコアパース
    func parseMyScore(html: String, iidxId: String, djName: String, versionName: String) {
        Log.debugStart(cls: String(describing: self), method: #function)

        if let doc = try? HTML(html: html, encoding: .utf8) {
            if doc.css("div.series-all").count == 0 {
                Log.error(cls: String(describing: self), method: #function, msg: Const.Log.SCRAPING_001)
                stopFlg = true
                return
            }

            // シリーズ全体<table>を一行毎に取得
            for node1 in doc.css("div.series-all")[0].css("tr") {
                
                if isCancel(msg: "parseMyScore " + versionName) { return }

                let bScore: MyScore = MyScore()
                let nScore: MyScore = MyScore()
                let hScore: MyScore = MyScore()
                let aScore: MyScore = MyScore()
                let lScore: MyScore = MyScore()
                
                bScore.difficultyId = Const.Value.Difficulty.BEGINNER
                nScore.difficultyId = Const.Value.Difficulty.NORMAL
                hScore.difficultyId = Const.Value.Difficulty.HYPER
                aScore.difficultyId = Const.Value.Difficulty.ANOTHER
                lScore.difficultyId = Const.Value.Difficulty.LEGGENDARIA
                
                for node2 in node1.css("a") {
                    // title
                    let title: String = node2.text!
                    bScore.title = title
                    nScore.title = title
                    hScore.title = title
                    aScore.title = title
                    lScore.title = title
                    
                    // 進捗
                    DispatchQueue.main.async {
                        self.mainVC.progressLbl.text
                            = djName + " " + versionName + " " + title
                    }
                    

                    // ミスカウント取り込みありの場合のみ
                    // 曲ページlinkより選曲回数、ミスカウントを取得
                    if missCountFlg {
                        let url: String = (node2["href"]?.description)!
                        let data: NSData = CommonMethod.getRequest(dataUrl: "\(Const.Url.KONAMI)\(url)"
                            , cookieStr: CommonData.Import.cookieStr)
                        // 曲ページhtmlパース
                        if let doc = try? HTML(html: String(data: data as Data, encoding: .windows31j) ?? "", encoding: .utf8) {
                            
                            // 選曲回数
                            for node in doc.css("div.music-playtime")[0].css("li") {
                                let selectCntText: String = node.text!
                                var selectCntStr: String = String(selectCntText.suffix(2))
                                selectCntStr.replaceSubrange(selectCntStr.range(of: "回")!, with: "")
                                let selectCnt: Int = Int(selectCntStr) ?? 0
                                // SP
                                if playStyle == Const.Value.PlayStyle.SINGLE && selectCntText.range(of: "SP") != nil {
                                    bScore.selectCount = selectCnt
                                    nScore.selectCount = selectCnt
                                    hScore.selectCount = selectCnt
                                    aScore.selectCount = selectCnt
                                    lScore.selectCount = selectCnt
                                    // DP
                                } else if playStyle == Const.Value.PlayStyle.DOUBLE && selectCntText.range(of: "DP") != nil {
                                    bScore.selectCount = selectCnt
                                    nScore.selectCount = selectCnt
                                    hScore.selectCount = selectCnt
                                    aScore.selectCount = selectCnt
                                    lScore.selectCount = selectCnt
                                }
                            }
                            
                            // ミスカウント
                            for node in doc.css("div.music-detail") {
                                let misscnt: String = node.css("td")[7].text!
                                let dif: String = node.css("th")[0].text ?? ""
                                // SP
                                if playStyle == Const.Value.PlayStyle.SINGLE {
                                    if dif == "SP BEGINNER" {
                                        bScore.missCount = misscnt
                                    } else if dif == "SP NORMAL" {
                                        nScore.missCount = misscnt
                                    } else if dif == "SP HYPER" {
                                        hScore.missCount = misscnt
                                    } else if dif == "SP ANOTHER" {
                                        aScore.missCount = misscnt
                                    } else if dif == "SP LEGGENDARIA" {
                                        lScore.missCount = misscnt
                                    }
                                // DP
                                } else {
                                    if dif == "DP BEGINNER" {
                                        bScore.missCount = misscnt
                                    } else if dif == "DP NORMAL" {
                                        nScore.missCount = misscnt
                                    } else if dif == "DP HYPER" {
                                        hScore.missCount = misscnt
                                    } else if dif == "DP ANOTHER" {
                                        aScore.missCount = misscnt
                                    } else if dif == "DP LEGGENDARIA" {
                                        lScore.missCount = misscnt
                                    }
                                }
                            }
                        }
                    } else {
                        bScore.selectCount = 0
                        nScore.selectCount = 0
                        hScore.selectCount = 0
                        aScore.selectCount = 0
                        lScore.selectCount = 0
                        bScore.missCount = Const.Label.Score.HYPHEN
                        nScore.missCount = Const.Label.Score.HYPHEN
                        hScore.missCount = Const.Label.Score.HYPHEN
                        aScore.missCount = Const.Label.Score.HYPHEN
                        lScore.missCount = Const.Label.Score.HYPHEN
                    }
                }
                
                // スコア行以外は無視
                if nScore.title != nil {
                    var clearlump: Int = 0
                    var djlevel: Int = 0
                    var scoreStr: String = ""
                    
                    for node3 in node1.css("div.score-cel") {
                        var i: Int = 0
                        for node4 in node3.css("img") {
                            let src: String = node4["src"] ?? ""
                            // clearlump
                            if i == 0 { clearlump = getClearLump(src: src) }
                            // djlevel
                            if i == 1 { djlevel = getDjLevel(src: src) }
                            i += 1
                        }
                        //score
                        scoreStr = (node3.innerHTML?.description.components(separatedBy: "<br>")[3]
                            .trimmingCharacters(in: .whitespaces))!
                        // N or H or A
                        switch node3.css("span")[0].text {
                        case "BEGINNER":
                            bScore.clearLump = clearlump
                            bScore.djLevel = djlevel
                            bScore.score = scoreStr
                        case "NORMAL":
                            nScore.clearLump = clearlump
                            nScore.djLevel = djlevel
                            nScore.score = scoreStr
                        case "HYPER":
                            hScore.clearLump = clearlump
                            hScore.djLevel = djlevel
                            hScore.score = scoreStr
                        case "ANOTHER":
                            aScore.clearLump = clearlump
                            aScore.djLevel = djlevel
                            aScore.score = scoreStr
                        case "LEGGENDARIA":
                            lScore.clearLump = clearlump
                            lScore.djLevel = djlevel
                            lScore.score = scoreStr
                        default:
                            Log.error(cls: String(describing: self), method: #function
                                , msg: Const.Log.SCRAPING_002)
                        }
                    }
                    // プレイスタイル
                    bScore.playStyle = playStyle
                    nScore.playStyle = playStyle
                    hScore.playStyle = playStyle
                    aScore.playStyle = playStyle
                    lScore.playStyle = playStyle
                    // scores配列に追加
                    myScoreArray.append(bScore)
                    myScoreArray.append(nScore)
                    myScoreArray.append(hScore)
                    myScoreArray.append(aScore)
                    myScoreArray.append(lScore)
                }
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// ライバルスコアパース
    func parseRivalScore(html: String, iidxId: String, djName: String, versionName: String) {
        Log.debugStart(cls: String(describing: self), method: #function)

            if let doc = try? HTML(html: html, encoding: .utf8) {
                if doc.css("div.series-all").count == 0 {
                    Log.error(cls: String(describing: self), method: #function, msg: Const.Log.SCRAPING_001)
                    stopFlg = true
                    return
                }
                
                // シリーズ全体<table>を一行毎に取得
                for node1 in doc.css("div.series-all")[0].css("tr") {
                    
                    if isCancel(msg: "parseRivalScore " + versionName) { return }

                    let bScore: RivalScore = RivalScore()
                    let nScore: RivalScore = RivalScore()
                    let hScore: RivalScore = RivalScore()
                    let aScore: RivalScore = RivalScore()
                    let lScore: RivalScore = RivalScore()
                    
                    bScore.difficultyId = Const.Value.Difficulty.BEGINNER
                    nScore.difficultyId = Const.Value.Difficulty.NORMAL
                    hScore.difficultyId = Const.Value.Difficulty.HYPER
                    aScore.difficultyId = Const.Value.Difficulty.ANOTHER
                    lScore.difficultyId = Const.Value.Difficulty.LEGGENDARIA
                    bScore.iidxId = iidxId
                    nScore.iidxId = iidxId
                    hScore.iidxId = iidxId
                    aScore.iidxId = iidxId
                    lScore.iidxId = iidxId
                    
                    for node2 in node1.css("a") {
                        // title
                        let title: String = node2.text!
                        bScore.title = title
                        nScore.title = title
                        hScore.title = title
                        aScore.title = title
                        lScore.title = title
                        
                        // 進捗
                        DispatchQueue.main.async {
                            self.mainVC.progressLbl.text
                                = djName + " " + versionName + " " + title
                        }
                        
                        // ミスカウント取り込みありの場合のみ
                        // 曲ページlinkよりミスカウントを取得
                        if missCountFlg {
                            let url: String = (node2["href"]?.description)!
                            let data: NSData = CommonMethod.getRequest(dataUrl: "\(Const.Url.KONAMI)\(url)"
                                , cookieStr: CommonData.Import.cookieStr)
                            
                            // 曲ページhtmlパース
                            if let doc = try? HTML(html: String(data: data as Data, encoding: .windows31j) ?? "", encoding: .utf8) {
                                
                                // ミスカウント
                                for node in doc.css("div.music-detail-rival") {
                                    let misscnt: String = node.css("td")[14].text!
                                    let dif: String = node.css("th")[0].text ?? ""
                                    // SP
                                    if playStyle == Const.Value.PlayStyle.SINGLE {
                                        if dif == "SP BEGINNER" {
                                            bScore.missCount = misscnt
                                        } else if dif == "SP NORMAL" {
                                            nScore.missCount = misscnt
                                        } else if dif == "SP HYPER" {
                                            hScore.missCount = misscnt
                                        } else if dif == "SP ANOTHER" {
                                            aScore.missCount = misscnt
                                        } else if dif == "SP LEGGENDARIA" {
                                            lScore.missCount = misscnt
                                        }
                                        // DP
                                    } else {
                                        if dif == "DP BEGINNER" {
                                            bScore.missCount = misscnt
                                        } else if dif == "DP NORMAL" {
                                            nScore.missCount = misscnt
                                        } else if dif == "DP HYPER" {
                                            hScore.missCount = misscnt
                                        } else if dif == "DP ANOTHER" {
                                            aScore.missCount = misscnt
                                        } else if dif == "DP LEGGENDARIA" {
                                            lScore.missCount = misscnt
                                        }
                                    }
                                }
                            }
                        } else {
                            bScore.missCount = Const.Label.Score.HYPHEN
                            nScore.missCount = Const.Label.Score.HYPHEN
                            hScore.missCount = Const.Label.Score.HYPHEN
                            aScore.missCount = Const.Label.Score.HYPHEN
                            lScore.missCount = Const.Label.Score.HYPHEN
                        }
                    }
                    
                    // スコア行以外は無視
                    if nScore.title != nil {
                        var clearlump: Int = 0
                        var djlevel: Int = 0
                        var scoreStr: String = ""
                        
                        for node3 in node1.css("div.score-cel") {
                            var i: Int = 0
                            for node4 in node3.css("img") {
                                let src: String = node4["src"] ?? ""
                                // clearlump
                                if i == 0 { clearlump = getClearLump(src: src) }
                                // djlevel
                                if i == 1 { djlevel = getDjLevel(src: src) }
                                i += 1
                            }
                            //score
                            scoreStr = (node3.innerHTML?.description.components(separatedBy: "<br>")[3]
                                .trimmingCharacters(in: .whitespaces))!
                            // N or H or A
                            switch node3.css("span")[0].text {
                            case "BEGINNER":
                                bScore.clearLump = clearlump
                                bScore.djLevel = djlevel
                                bScore.score = scoreStr
                            case "NORMAL":
                                nScore.clearLump = clearlump
                                nScore.djLevel = djlevel
                                nScore.score = scoreStr
                            case "HYPER":
                                hScore.clearLump = clearlump
                                hScore.djLevel = djlevel
                                hScore.score = scoreStr
                            case "ANOTHER":
                                aScore.clearLump = clearlump
                                aScore.djLevel = djlevel
                                aScore.score = scoreStr
                            case "LEGGENDARIA":
                                lScore.clearLump = clearlump
                                lScore.djLevel = djlevel
                                lScore.score = scoreStr
                            default:
                                Log.error(cls: String(describing: self), method: #function
                                    , msg: Const.Log.SCRAPING_002)
                            }
                        }
                        // プレイスタイル
                        bScore.playStyle = playStyle
                        nScore.playStyle = playStyle
                        hScore.playStyle = playStyle
                        aScore.playStyle = playStyle
                        lScore.playStyle = playStyle
                        // scores配列に追加
                        rivalScoreArray.append(bScore)
                        rivalScoreArray.append(nScore)
                        rivalScoreArray.append(hScore)
                        rivalScoreArray.append(aScore)
                        rivalScoreArray.append(lScore)
                    }
                }
            }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// クリアランプ取得
    private func getClearLump(src: String) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret: Int = 0
        
        // clearlump
        if src.range(of: "clflg0.gif") != nil {
            ret = Const.Value.ClearLump.NOPLAY
        } else if src.range(of: "clflg1.gif") != nil {
            ret = Const.Value.ClearLump.FAILED
        } else if src.range(of: "clflg2.gif") != nil {
            ret = Const.Value.ClearLump.ACLEAR
        } else if src.range(of: "clflg3.gif") != nil {
            ret = Const.Value.ClearLump.ECLEAR
        } else if src.range(of: "clflg4.gif") != nil {
            ret = Const.Value.ClearLump.CLEAR
        } else if src.range(of: "clflg5.gif") != nil {
            ret = Const.Value.ClearLump.HCLEAR
        } else if src.range(of: "clflg6.gif") != nil {
            ret = Const.Value.ClearLump.EXHCLEAR
        } else if src.range(of: "clflg7.gif") != nil {
            ret = Const.Value.ClearLump.FCOMBO
        } else {
            Log.error(cls: String(describing: self), method: #function, msg: Const.Log.SCRAPING_003)
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }

    
    /// DJレベル取得
    private func getDjLevel(src: String) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret: Int = 0
        
        // djlevel
        if src.range(of: "/---.gif") != nil {
            ret = Const.Value.DjLevel.NOPLAY
        } else if src.range(of: "/F.gif") != nil {
            ret = Const.Value.DjLevel.F
        } else if src.range(of: "/E.gif") != nil {
            ret = Const.Value.DjLevel.E
        } else if src.range(of: "/D.gif") != nil {
            ret = Const.Value.DjLevel.D
        } else if src.range(of: "/C.gif") != nil {
            ret = Const.Value.DjLevel.C
        } else if src.range(of: "/B.gif") != nil {
            ret = Const.Value.DjLevel.B
        } else if src.range(of: "/A.gif") != nil {
            ret = Const.Value.DjLevel.A
        } else if src.range(of: "/AA.gif") != nil {
            ret = Const.Value.DjLevel.AA
        } else if src.range(of: "/AAA.gif") != nil {
            ret = Const.Value.DjLevel.AAA
        } else {
            Log.error(cls: String(describing: self), method: #function, msg: Const.Log.SCRAPING_004)
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
}
