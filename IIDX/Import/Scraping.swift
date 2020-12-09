//
//  Scraping.swift
//  IIDX
//
//  Created by umeme on 2019/08/29.
//  Copyright © 2019 umeme. All rights reserved.
//

import Kanna

extension Import {
    
    /*
     マイステータスページHTMLパース
     */
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
                CommonMethod.saveImage(image: UIImage(url: url), fileName: Const.Image.Qpro().getQproFileName())
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
    
    /*
     ライバルリストページHTMLパース
     */
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

    /*
     マイスコア難易度別ページパース
     */
    func parseMyScoreTargetLevel(html: String, iidxId: String, djName: String, levelName: String, offset: Int) -> Bool {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if let doc = try? HTML(html: html, encoding: .utf8) {
            if doc.css("div.series-difficulty").count == 0 {
                if offset == 0 {
                    // 取込失敗とみなす
                    Log.error(cls: String(describing: self), method: #function, msg: Const.Log.SCRAPING_001)
                    stopFlg = true
                }
                // 最後のページまで終了
                return false
            }

            // １行ごとに取得
            for node1 in doc.css("div.series-difficulty")[0].css("tr") {
                
                if isCancel(msg: "parseMyScore " + levelName) { return false }
                
                // ヘッダ行は飛ばす
                if node1.css("a").count == 0 {
                    continue
                }
                
                let myScore: MyScore = MyScore()
                
                // title
                let title: String = node1.css("a")[0].text!
                // difficulty
                let difficulty: Int = getDifficulty(src: node1.css("td")[1].text!)
                // djLevel
                let djLevel: Int = getDjLevel(src: node1.css("td")[2].innerHTML!)
                // score
                var scoreStr: String = node1.css("td")[3].innerHTML!
                scoreStr.replaceSubrange(scoreStr.range(of: "<br>")!, with: "")
                let score = Int(scoreStr.components(separatedBy: "(")[0])
                // pgreat
                let pgreatStr = scoreStr.components(separatedBy: "(")[1].components(separatedBy: "/")[0]
                let pgreat = Int(pgreatStr)
                // great
                let greatStr = scoreStr.components(separatedBy: "(")[1].components(separatedBy: "/")[1].replacingOccurrences(of: ")", with: "")
                let great = Int(greatStr)
                // clearLump
                let clearLump: Int = getClearLump(src: node1.css("td")[4].innerHTML!)
                
                myScore.title = title
                myScore.difficultyId = difficulty
                myScore.djLevel = djLevel
                myScore.score = score ?? 0
                myScore.pgreat = pgreat ?? 0
                myScore.great = great ?? 0
                myScore.clearLump = clearLump
                myScore.playStyle = playStyle
                
                // ミスカウントありの場合のみ各曲ページより取得
                if missCountFlg {
                    let url: String = (node1.css("a")[0]["href"]?.description)!
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
                            if playStyle == Const.Value.PlayStyle.SINGLE {
                                if selectCntText.contains("SP") {
                                    myScore.selectCount = selectCnt
                                }
                            // DP
                            } else {
                                if selectCntText.contains("DP") {
                                    myScore.selectCount = selectCnt
                                }
                            }
                        }
                        
                        // ミスカウント
                        for node in doc.css("div.music-detail") {
                            let misscnt: Int = Int(node.css("td")[7].text!) ?? 9999
                            let dif: String = node.css("th")[0].text ?? ""
                            // SP
                            if playStyle == Const.Value.PlayStyle.SINGLE {
                                if dif.contains("SP") && dif.contains(node1.css("td")[1].text!) {
                                    myScore.missCount = misscnt
                                }
                            // DP
                            } else {
                                if dif.contains("DP") && dif.contains(node1.css("td")[1].text!) {
                                    myScore.missCount = misscnt
                                }
                            }
                        }
                    }
                } else {
                    myScore.selectCount = 0
                    myScore.missCount = 9999
                }
                
                // 配列に追加
                myScoreArray.append(myScore)
                
                // 進捗
                DispatchQueue.main.async {
                    self.mainVC.progressLbl.text
                        = djName + " " + levelName + " " + title
                }
            }
        }
        print(myScoreArray)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return true
    }

    /*
     ライバルスコア難易度別ページパース
     */
    func parseRivalScoreTargetLevel(html: String, iidxId: String, djName: String, levelName: String, offset: Int) -> Bool {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if let doc = try? HTML(html: html, encoding: .utf8) {
            if doc.css("div.series-difficulty").count == 0 {
                if offset == 0 {
                    // 取込失敗とみなす
                    Log.error(cls: String(describing: self), method: #function, msg: Const.Log.SCRAPING_001)
                    stopFlg = true
                }
                // 最後のページまで終了
                return false
            }

            // １行ごとに取得
            for node1 in doc.css("div.series-difficulty")[0].css("tr") {
                
                if isCancel(msg: "parseRivalScore " + levelName) { return false }
                
                // ヘッダ行は飛ばす
                if node1.css("a").count == 0 {
                    continue
                }
                
                let rivalScore: RivalScore = RivalScore()
                
                // title
                let title: String = node1.css("a")[0].text!
                // difficulty
                let difficulty: Int = getDifficulty(src: node1.css("td")[1].text!)
                // djLevel
                let djLevel: Int = getDjLevel(src: node1.css("td")[2].innerHTML!)
                // score
                var scoreStr: String = node1.css("td")[3].innerHTML!
                scoreStr.replaceSubrange(scoreStr.range(of: "<br>")!, with: "")
                let score = Int(scoreStr.components(separatedBy: "(")[0])
                // pgreat
                let pgreatStr = scoreStr.components(separatedBy: "(")[1].components(separatedBy: "/")[0]
                let pgreat = Int(pgreatStr)
                // great
                let greatStr = scoreStr.components(separatedBy: "(")[1].components(separatedBy: "/")[1].replacingOccurrences(of: ")", with: "")
                let great = Int(greatStr)
                // clearLump
                let clearLump: Int = getClearLump(src: node1.css("td")[4].innerHTML!)
                
                rivalScore.title = title
                rivalScore.difficultyId = difficulty
                rivalScore.djLevel = djLevel
                rivalScore.score = score ?? 0
                rivalScore.pgreat = pgreat ?? 0
                rivalScore.great = great ?? 0
                rivalScore.clearLump = clearLump
                rivalScore.playStyle = playStyle
                rivalScore.iidxId = iidxId
                
                // ミスカウントありの場合のみ各曲ページより取得
                if missCountFlg {
                    let url: String = (node1.css("a")[0]["href"]?.description)!
                    let data: NSData = CommonMethod.getRequest(dataUrl: "\(Const.Url.KONAMI)\(url)"
                        , cookieStr: CommonData.Import.cookieStr)
                    // 曲ページhtmlパース
                    if let doc = try? HTML(html: String(data: data as Data, encoding: .windows31j) ?? "", encoding: .utf8) {
                        // ミスカウント
                        for node in doc.css("div.music-detail-rival") {
                            let misscnt: Int = Int(node.css("td")[14].text!) ?? 9999
                            let dif: String = node.css("th")[0].text ?? ""
                            // SP
                            if playStyle == Const.Value.PlayStyle.SINGLE {
                                if dif.contains("SP") && dif.contains(node1.css("td")[1].text!) {
                                    rivalScore.missCount = misscnt
                                }
                            // DP
                            } else {
                                if dif.contains("DP") && dif.contains(node1.css("td")[1].text!) {
                                    rivalScore.missCount = misscnt
                                }
                            }
                        }
                    }
                } else {
                    rivalScore.missCount = 9999
                }

                // 配列に追加
                rivalScoreArray.append(rivalScore)
                
                // 進捗
                DispatchQueue.main.async {
                    self.mainVC.progressLbl.text
                        = djName + " " + levelName + " " + title
                }
            }
        }
        print(rivalScoreArray)
        Log.debugEnd(cls: String(describing: self), method: #function)
        return true
    }

    /*
     マイスコアシリーズページパース
     */
    func parseMyScoreTargetVersion(html: String, iidxId: String, djName: String, versionName: String) {
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
                                let misscnt: Int = Int(node.css("td")[7].text!) ?? 9999
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
                        bScore.missCount = 9999
                        nScore.missCount = 9999
                        hScore.missCount = 9999
                        aScore.missCount = 9999
                        lScore.missCount = 9999
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
                        let score = Int(scoreStr.components(separatedBy: "(")[0])
                        // pgreat
                        let pgreatStr = scoreStr.components(separatedBy: "(")[1].components(separatedBy: "/")[0]
                        let pgreat = Int(pgreatStr)
                        // great
                        let greatStr = scoreStr.components(separatedBy: "(")[1].components(separatedBy: "/")[1].replacingOccurrences(of: ")", with: "")
                        let great = Int(greatStr)

                        // N or H or A
                        switch node3.css("span")[0].text {
                        case "BEGINNER":
                            bScore.clearLump = clearlump
                            bScore.djLevel = djlevel
                            bScore.score = score ?? 0
                            bScore.pgreat = pgreat ?? 0
                            bScore.great = great ?? 0
                        case "NORMAL":
                            nScore.clearLump = clearlump
                            nScore.djLevel = djlevel
                            nScore.score = score ?? 0
                            nScore.pgreat = pgreat ?? 0
                            nScore.great = great ?? 0
                        case "HYPER":
                            hScore.clearLump = clearlump
                            hScore.djLevel = djlevel
                            hScore.score = score ?? 0
                            hScore.pgreat = pgreat ?? 0
                            hScore.great = great ?? 0
                        case "ANOTHER":
                            aScore.clearLump = clearlump
                            aScore.djLevel = djlevel
                            aScore.score = score ?? 0
                            aScore.pgreat = pgreat ?? 0
                            aScore.great = great ?? 0
                        case "LEGGENDARIA":
                            lScore.clearLump = clearlump
                            lScore.djLevel = djlevel
                            lScore.score = score ?? 0
                            lScore.pgreat = pgreat ?? 0
                            lScore.great = great ?? 0
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
    
    /*
     ライバルスコアシリーズページパース
     */
    func parseRivalScoreTargetVersion(html: String, iidxId: String, djName: String, versionName: String) {
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
                                    let misscnt: Int = Int(node.css("td")[14].text!) ?? 9999
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
                            bScore.missCount = 9999
                            nScore.missCount = 9999
                            hScore.missCount = 9999
                            aScore.missCount = 9999
                            lScore.missCount = 9999
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
                            let score = Int(scoreStr.components(separatedBy: "(")[0])
                            // pgreat
                            let pgreatStr = scoreStr.components(separatedBy: "(")[1].components(separatedBy: "/")[0]
                            let pgreat = Int(pgreatStr)
                            // great
                            let greatStr = scoreStr.components(separatedBy: "(")[1].components(separatedBy: "/")[1].replacingOccurrences(of: ")", with: "")
                            let great = Int(greatStr)
                            
                            // N or H or A
                            switch node3.css("span")[0].text {
                            case "BEGINNER":
                                bScore.clearLump = clearlump
                                bScore.djLevel = djlevel
                                bScore.score = score ?? 0
                                bScore.pgreat = pgreat ?? 0
                                bScore.great = great ?? 0
                            case "NORMAL":
                                nScore.clearLump = clearlump
                                nScore.djLevel = djlevel
                                nScore.score = score ?? 0
                                nScore.pgreat = pgreat ?? 0
                                nScore.great = great ?? 0
                            case "HYPER":
                                hScore.clearLump = clearlump
                                hScore.djLevel = djlevel
                                hScore.score = score ?? 0
                                hScore.pgreat = pgreat ?? 0
                                hScore.great = great ?? 0
                            case "ANOTHER":
                                aScore.clearLump = clearlump
                                aScore.djLevel = djlevel
                                aScore.score = score ?? 0
                                aScore.pgreat = pgreat ?? 0
                                aScore.great = great ?? 0
                            case "LEGGENDARIA":
                                lScore.clearLump = clearlump
                                lScore.djLevel = djlevel
                                lScore.score = score ?? 0
                                lScore.pgreat = pgreat ?? 0
                                lScore.great = great ?? 0
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
    
    /*
     CSVページパース
     */
    func parseMyScoreTargetCsv(html: String) {
        Log.debugStart(cls: String(describing: self), method: #function)

        if let doc = try? HTML(html: html, encoding: .utf8) {
            if doc.css("#score_data").count == 0 {
                Log.error(cls: String(describing: self), method: #function, msg: Const.Log.SCRAPING_001)
                stopFlg = true
                return
            }
            
            // 画面のCSV文字列取得
            let csv: String = doc.css("#score_data")[0].text ?? ""
            
            // 各行取得
            let records: [String] = csv.components(separatedBy: "\r")
            for record in records {
                // 最終行は空
                if (record == "") { continue }
                
                // 各データ取得
                let columns: [String] = record.components(separatedBy: ",")
                // ヘッダ行無視
                if (columns[0] == "バージョン") { continue }
                
                // BIGINNER
                var score: MyScore = MyScore()
                score.difficultyId = Const.Value.Difficulty.BEGINNER
                score.title = columns[1]
                score.selectCount = Int(columns[4]) ?? 0
                score.score = Int(columns[6]) ?? 0
                score.pgreat = Int(columns[7]) ?? 0
                score.great = Int(columns[8]) ?? 0
                score.missCount = convertMissCountForCsv(missCount: columns[9])
                score.clearLump = getClearLumpForCsv(column: columns[10])
                score.djLevel = getDjLevelForCsv(column: columns[11])
                myScoreArray.append(score)

                // NORMAL
                score = MyScore()
                score.difficultyId = Const.Value.Difficulty.NORMAL
                score.title = columns[1]
                score.selectCount = Int(columns[4]) ?? 0
                score.score = Int(columns[13]) ?? 0
                score.pgreat = Int(columns[14]) ?? 0
                score.great = Int(columns[15]) ?? 0
                score.missCount = convertMissCountForCsv(missCount: columns[16])
                score.clearLump = getClearLumpForCsv(column: columns[17])
                score.djLevel = getDjLevelForCsv(column: columns[18])
                myScoreArray.append(score)

                // HYPER
                score = MyScore()
                score.difficultyId = Const.Value.Difficulty.HYPER
                score.title = columns[1]
                score.selectCount = Int(columns[4]) ?? 0
                score.score = Int(columns[20]) ?? 0
                score.pgreat = Int(columns[21]) ?? 0
                score.great = Int(columns[22]) ?? 0
                score.missCount = convertMissCountForCsv(missCount: columns[23])
                score.clearLump = getClearLumpForCsv(column: columns[24])
                score.djLevel = getDjLevelForCsv(column: columns[25])
                myScoreArray.append(score)

                // ANOTHER
                score = MyScore()
                score.difficultyId = Const.Value.Difficulty.ANOTHER
                score.title = columns[1]
                score.selectCount = Int(columns[4]) ?? 0
                score.score = Int(columns[27]) ?? 0
                score.pgreat = Int(columns[28]) ?? 0
                score.great = Int(columns[29]) ?? 0
                score.missCount = convertMissCountForCsv(missCount: columns[30])
                score.clearLump = getClearLumpForCsv(column: columns[31])
                score.djLevel = getDjLevelForCsv(column: columns[32])
                myScoreArray.append(score)

                // LEGGENDARIA
                score = MyScore()
                score.difficultyId = Const.Value.Difficulty.LEGGENDARIA
                score.title = columns[1]
                score.selectCount = Int(columns[4]) ?? 0
                score.score = Int(columns[34]) ?? 0
                score.pgreat = Int(columns[35]) ?? 0
                score.great = Int(columns[36]) ?? 0
                score.missCount = convertMissCountForCsv(missCount: columns[37])
                score.clearLump = getClearLumpForCsv(column: columns[38])
                score.djLevel = getDjLevelForCsv(column: columns[39])
                myScoreArray.append(score)
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     ミスカウント変換（CSV用）
     */
    private func convertMissCountForCsv(missCount: String) -> Int {
        if missCount == "---" {
            return 9999
        } else {
            return Int(missCount) ?? 9999
        }
    }
    
    /*
     クリアランプ取得（CSV用）
     */
    private func getClearLumpForCsv(column: String) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret: Int = 0
        
        // clearlump
        switch column {
            case "NO PLAY":
                ret = Const.Value.ClearLump.NOPLAY
            case "FAILED":
                ret = Const.Value.ClearLump.FAILED
            case "ASSIST CLEAR":
            ret = Const.Value.ClearLump.ACLEAR
            case "EASY CLEAR":
                ret = Const.Value.ClearLump.ECLEAR
            case "CLEAR":
                ret = Const.Value.ClearLump.CLEAR
            case "HARD CLEAR":
                ret = Const.Value.ClearLump.HCLEAR
            case "EX HARD CLEAR":
                ret = Const.Value.ClearLump.EXHCLEAR
            case "FULLCOMBO CLEAR":
                ret = Const.Value.ClearLump.FCOMBO
            default:
                Log.error(cls: String(describing: self), method: #function, msg: Const.Log.SCRAPING_003)
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }

    /*
     DJレベル取得（CSV用）
     */
    private func getDjLevelForCsv(column: String) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret: Int = 0
        
        // djlevel
        switch column {
            case "---":
                ret = Const.Value.DjLevel.NOPLAY
            case "F":
                ret = Const.Value.DjLevel.F
            case "E":
                ret = Const.Value.DjLevel.E
            case "D":
                ret = Const.Value.DjLevel.D
            case "C":
                ret = Const.Value.DjLevel.C
            case "B":
                ret = Const.Value.DjLevel.B
            case "A":
                ret = Const.Value.DjLevel.A
            case "AA":
                ret = Const.Value.DjLevel.AA
            case "AAA":
                ret = Const.Value.DjLevel.AAA
            default:
                Log.error(cls: String(describing: self), method: #function, msg: Const.Log.SCRAPING_004)
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }

    
    /*
     クリアランプ取得
     */
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

    /*
     DJレベル取得
     */
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
    
    /*
     難易度取得
     */
    private func getDifficulty(src: String) -> Int {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret: Int = 0
        
        if src.range(of: "BEGINNER") != nil {
            ret = Const.Value.Difficulty.BEGINNER
        } else if src.range(of: "NORMAL") != nil {
            ret = Const.Value.Difficulty.NORMAL
        } else if src.range(of: "HYPER") != nil {
            ret = Const.Value.Difficulty.HYPER
        } else if src.range(of: "ANOTHER") != nil {
            ret = Const.Value.Difficulty.ANOTHER
        } else if src.range(of: "LEGGENDARIA") != nil {
            ret = Const.Value.Difficulty.LEGGENDARIA
        } else {
            Log.error(cls: String(describing: self), method: #function, msg: Const.Log.SCRAPING_002)
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }

}
