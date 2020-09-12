//
//  Import.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class Import {
    
    var mainVC: MainViewController
    let myUD: MyUserDefaults = MyUserDefaults()
    var playStyle: Int
    var firstLoadFlg: Bool
    let dispatchGroup: DispatchGroup = DispatchGroup()
    let dispatchQueue: DispatchQueue = DispatchQueue(label: "Import Thread Group")
    var stopFlg: Bool = false
    var backgroundTaskId1 = UIBackgroundTaskIdentifier(rawValue: 0)
    var backgroundTaskId2 = UIBackgroundTaskIdentifier(rawValue: 0)
    var backgroundTaskId3 = UIBackgroundTaskIdentifier(rawValue: 0)
    var myStatuses: [MyStatus] = [MyStatus]()
    var rivals: [RivalStatus] = [RivalStatus]()
    var myScoreArray: [MyScore] = [MyScore]()
    var rivalScoreArray: [RivalScore] = [RivalScore]()
    var missCountFlg: Bool = true
    var noTargetFlg: Bool = false
    
    
    init(mainVC: MainViewController) {
        self.mainVC = mainVC
        self.playStyle = myUD.getPlayStyle()
        self.firstLoadFlg = myUD.getFirstLoadFlg()
        self.missCountFlg = myUD.getMissCountFlg()
    }

    
    /// データ取り込み処理
    func doImport() {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // ロード中フラグ
        CommonData.Import.loadingFlg = true
        
        // UI変更
        // インポートボタンをキャンセルボタンに変更
        self.mainVC.importBtn.setImage(UIImage(named: Const.Image.Operation.IMPORT_CANCEL), for: .normal)
        // プレイスタイルボタンを無効化
        self.mainVC.playStyleBtn.isEnabled = false
        // 設定ボタンを無効化
        self.mainVC.settingBtn.isEnabled = false
        self.mainVC.settingBtn.setImage(UIImage(named: Const.Image.Button.SETTING_NG), for: .normal)
        
        // 進捗View表示
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                self.mainVC.progressView.alpha = 0.9
        }, completion: nil)
        self.mainVC.progressLbl.text = Const.Label.LOADING
        
        
        // スレッド開始
        dispatchGroup.enter()
        dispatchQueue.async(group: dispatchGroup) {
            Log.debugStart(cls: String(describing: self), method: #function + "Thread")
            
            let startDate = Date()

            // バックグラウンド処理開始
            self.backgroundTaskId1 = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                self.backgroundTaskId2 = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                    self.backgroundTaskId3 = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                    })
                    UIApplication.shared.endBackgroundTask(self.backgroundTaskId2)
                })
                UIApplication.shared.endBackgroundTask(self.backgroundTaskId1)
            })
            
            let seedRealm: Realm = CommonMethod.createSeedRealm()
            let scoreRealm: Realm = CommonMethod.createScoreRealm()

            // マイステータスインポート
            self.importMyStatus()

            // ライバルリストインポート
            self.importRivalList()

            // スコアインポート
            let target: String = self.myUD.getTarget()
            self.importScores(target: target, seedRealm: seedRealm, scoreRealm: scoreRealm)

            // DB保存
            self.saveDB(target: target, seedRealm: seedRealm, scoreRealm: scoreRealm)
            
            // 処理時間計測
            let elapsed = Date().timeIntervalSince(startDate) as Double
            let formatedElapsed = String(format: "%.3f", elapsed)
            Log.debug(cls: String(describing: self), method: #function, msg: "計測時間: \(formatedElapsed)(s)")
            
            Log.debugEnd(cls: String(describing: self), method: #function + "Thread")
            self.dispatchGroup.leave()
            // バックグラウンド処理終了
            UIApplication.shared.endBackgroundTask(self.backgroundTaskId1)
            UIApplication.shared.endBackgroundTask(self.backgroundTaskId2)
            UIApplication.shared.endBackgroundTask(self.backgroundTaskId3)
        }

        // スレッド終了後に実行
        dispatchGroup.notify(queue: .main) {
            
            let vc: UIViewController = CommonMethod.getTopViewController() ?? UIViewController()
            if self.stopFlg {
                // キャンセル時
                if self.mainVC.cancelFlg {
                    CommonMethod.dispAlert(message: Const.Message.IMPORT_CANCEL, vc: vc)
                    self.mainVC.progressLbl.text = Const.Label.CANCELED
                // 取込レベルかバージョンが選択されていない時
                } else if self.noTargetFlg {
                    CommonMethod.dispAlert(message: Const.Message.NO_TARGET_LEVEL_VERSION, vc: vc)
                    self.mainVC.progressLbl.text = Const.Label.FAILED
                // 上記以外の中断
                } else {
                    CommonMethod.dispAlert(message: Const.Message.IMPORT_FAILED, vc: vc)
                    self.mainVC.progressLbl.text = Const.Label.FAILED
                }
                
            // 正常終了時
            } else {
                // アラート表示
                CommonMethod.dispAlert(message: Const.Message.IMPORT_COMPLETE, vc: vc)
                
                if self.firstLoadFlg {
                    // 初回インポート後は自分を設定
                    let scoreRealm: Realm = CommonMethod.createScoreRealm()
                    let myStatuses: Results<MyStatus> = scoreRealm.objects(MyStatus.self)
                    self.myUD.setTarget(target: myStatuses.first?.iidxId ?? "")
                }
                
                // 初回フラグ
                self.firstLoadFlg = false
                
                // UI変更
                if self.mainVC.filterBtn.isEnabled == false {
                    self.mainVC.filterBtn.isEnabled = true
                    self.mainVC.filterBtn.setImage(UIImage(named: Const.Image.Operation.FILTER_OK), for: .normal)
                    self.mainVC.sortBtn.isEnabled = true
                    self.mainVC.sortBtn.setImage(UIImage(named: Const.Image.Operation.SORT_OK), for: .normal)
                    self.mainVC.statisticsBtn.isEnabled = true
                    self.mainVC.statisticsBtn.setImage(UIImage(named: Const.Image.Operation.STATISTICS_OK), for: .normal)
                }
                self.mainVC.progressLbl.text = Const.Label.COMPLETE
            }

            // 以下成功失敗共通処理
            
            self.myUD.setFirstLoadFlg(firstLoadFlg: self.firstLoadFlg)
            
            // ロード中フラグ
            CommonData.Import.loadingFlg = false
            // 停止・キャンセルフラグ
            self.stopFlg = false
            self.mainVC.cancelFlg = false
            
            // 進捗View非表示
            UIView.animate(withDuration: 0.2, delay: 1.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                self.mainVC.progressView.alpha = 0.0
            }, completion: nil)
            
            // UI変更
            // キャンセルボタンをインポートボタンに変更
            self.mainVC.importBtn.setImage(UIImage(named: Const.Image.Operation.IMPORT), for: .normal)
            // プレイスタイルボタンを有効化
            self.mainVC.playStyleBtn.isEnabled = true
            // 設定ボタンを有効化
            self.mainVC.settingBtn.isEnabled = true
            self.mainVC.settingBtn.setImage(UIImage(named: Const.Image.Button.SETTING_OK), for: .normal)
            
            // 配列を空にする
            self.myScoreArray.removeAll()
            self.rivalScoreArray.removeAll()
            
            // listTVリロード
            let listVC: ListViewController = self.mainVC.children[0] as! ListViewController
            listVC.listTV.reloadData()
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// マイステータス取り込み
    private func importMyStatus() {
        Log.debugStart(cls: String(describing: self), method: #function)

        if isCancel(msg: "") { return }
        
        // HTML取得
        let data: NSData = CommonMethod.getRequest(dataUrl: Const.Url().getStatusUrl()
            , cookieStr: CommonData.Import.cookieStr)

        // htmlパース
        let htmlStr: String = String(data: data as Data, encoding: .windows31j) ?? ""
        self.parseMyStatus(html: htmlStr)
            
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// ライバルリスト取り込み
    private func importRivalList() {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if isCancel(msg: "") { return }
        
        // HTML取得
        let data: NSData = CommonMethod.getRequest(dataUrl: Const.Url().getRivalListUrl()
            , cookieStr: CommonData.Import.cookieStr)

        // htmlパース & DB保存
        let htmlStr: String = String(data: data as Data, encoding: .windows31j) ?? ""
        self.parseRivalList(html: htmlStr)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    

    /// スコア取り込み
    private func importScores(target: String, seedRealm: Realm, scoreRealm: Realm) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.info(cls: String(describing: self), method: #function, msg: "取り込み対象アカウント " + target)
        
        if isCancel(msg: "") { return }
        
        // UserDefalutより取込対象ページを取得
        let targetPage: Int = myUD.getTargetPage()
        
        switch targetPage {
            // 難易度別（レベル）ページより取得
            case Const.Value.TargetPage.LEVEL:
                // 取込対象レベル取得
                let targetLevelArray: [String] = myUD.getTargetPageLevelCheckArray()
                // チェックなしの場合
                if targetLevelArray.isEmpty {
                    self.stopFlg = true
                    self.noTargetFlg = true
                }
                // レベルソート
                var targetLevelArrayInt: [Int] = [Int]()
                for target in targetLevelArray {
                    targetLevelArrayInt.append(Int(target)!)
                }
                targetLevelArrayInt.sort()
            
                // 初回
                if firstLoadFlg {
                    // 登録用配列作成
                    self.makeMyScoreArrayTargetLevel(iidxId: "", djName: "", seedRealm: seedRealm, targetLevelArray: targetLevelArrayInt)

                // ２回め以降
                } else {
                    let myStatuses: Results<MyStatus> = scoreRealm.objects(MyStatus.self)
                        .filter("\(MyStatus.Types.iidxId.rawValue) = %@", target)
                    
                    // 自分
                    if !myStatuses.isEmpty {
                        // 登録用配列作成
                        self.makeMyScoreArrayTargetLevel(iidxId: target, djName: myStatuses.first?.djName ?? "", seedRealm: seedRealm, targetLevelArray: targetLevelArrayInt)
                        
                    // ライバル
                    } else {
                        // 登録用配列作成
                        self.makeRivalScoreArrayTargetLevel(iidxId: target, seedRealm: seedRealm, scoreRealm: scoreRealm, targetLevelArray: targetLevelArrayInt)
                    }
                }

            // シリーズ（バージョン）ページより取得
            case Const.Value.TargetPage.VERSION:
                // 取込対象バージョン取得
                let targetVersionArray: [String] = myUD.getTargetPageVersionCheckArray()
                // チェックなしの場合
                if targetVersionArray.isEmpty {
                    self.stopFlg = true
                    self.noTargetFlg = true
                }
                // ソート
                var targetVersionArrayInt: [Int] = [Int]()
                for target in targetVersionArray {
                    targetVersionArrayInt.append(Int(target)!)
                }
                targetVersionArrayInt.sort()
                
                // 初回
                if firstLoadFlg {
                    // 登録用配列作成
                    self.makeMyScoreArrayTargetVersion(iidxId: "", djName: "", seedRealm: seedRealm
                        , targetVersionArray: targetVersionArrayInt)

                // ２回め以降
                } else {
                    let myStatuses: Results<MyStatus> = scoreRealm.objects(MyStatus.self)
                        .filter("\(MyStatus.Types.iidxId.rawValue) = %@", target)
                    
                    // 自分
                    if !myStatuses.isEmpty {
                        // 登録用配列作成
                        self.makeMyScoreArrayTargetVersion(iidxId: target, djName:myStatuses.first?.djName ?? ""
                            ,seedRealm: seedRealm, targetVersionArray: targetVersionArrayInt)
                        
                    // ライバル
                    } else {
                        // 登録用配列作成
                        self.makeRivalScoreArrayTargetVersion(iidxId: target, seedRealm: seedRealm, scoreRealm: scoreRealm
                            , targetVersionArray: targetVersionArrayInt)
                    }
                }
        default:
            print("処理なし")
        }

        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    /*
     登録用配列作成（自分）（難易度別ページより取得）
     */
    private func makeMyScoreArrayTargetLevel(iidxId: String, djName: String, seedRealm: Realm
        , targetLevelArray: [Int]) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if isCancel(msg: "") { return }
        
        for lvl in targetLevelArray {
            // レベル取得
            let level: Code = seedRealm.objects(Code.self)
                .filter("\(Code.Types.kindCode.rawValue) = %@ and \(Code.Types.code.rawValue) = %@", Const.Value.kindCode.LEVEL, lvl).first ?? Code()
            
            // HTML取得
            let l = lvl - 1
            var offset: Int = 0
            var continueFlg = true
            while continueFlg {
                let data: NSData = CommonMethod.postRequest(dataUrl: Const.Url().getDifficultyUrl()
                    , postStr: "difficult=\(l)&style=\(String(describing: self.playStyle))&disp=1&offset=\(String(describing: offset))"
                    , cookieStr: CommonData.Import.cookieStr)

                // HTMLスクレイピング
                let djName: String = djName
                let htmlStr: String = String(data: data as Data, encoding: .windows31j) ?? ""
                continueFlg = self.parseMyScoreTargetLevel(html: htmlStr, iidxId: iidxId
                    , djName: djName, levelName: level.name ?? "", offset: offset)
                
                // 1ページ50件
                offset += 50
            }
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     登録用配列作成（ライバル）（難易度別ページより取得）
     */
    private func makeRivalScoreArrayTargetLevel(iidxId: String, seedRealm: Realm, scoreRealm: Realm
        , targetLevelArray: [Int]) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if isCancel(msg: "") { return }
        
        for lvl in targetLevelArray {
            // レベル取得
            let level: Code = seedRealm.objects(Code.self)
                .filter("\(Code.Types.kindCode.rawValue) = %@ and \(Code.Types.code.rawValue) = %@", Const.Value.kindCode.LEVEL, lvl).first ?? Code()
            
            // ライバルコード取得
            let rivalStatus: RivalStatus = scoreRealm.objects(RivalStatus.self)
                .filter("\(RivalStatus.Types.iidxId.rawValue) = %@ and \(RivalStatus.Types.playStyle.rawValue) = %@"
                    , iidxId, playStyle).first ?? RivalStatus()
            let code: String = rivalStatus.code ?? ""
            
            // HTML取得
            let l = lvl - 1
            var offset: Int = 0
            var continueFlg = true
            while continueFlg {
                let data: NSData = CommonMethod.postRequest(dataUrl: Const.Url().getDifficultyRivalUrl()
                    , postStr: "difficult=\(l)&style=\(String(describing: self.playStyle))&disp=1&offset=\(String(describing: offset))&rival=\(code)"
                    , cookieStr: CommonData.Import.cookieStr)

                // HTMLスクレイピング
                let djName: String = rivalStatus.djName ?? ""
                let htmlStr: String = String(data: data as Data, encoding: .windows31j) ?? ""
                continueFlg = self.parseRivalScoreTargetLevel(html: htmlStr, iidxId: iidxId
                    , djName: djName, levelName: level.name ?? "", offset: offset)
                
                // 1ページ50件
                offset += 50
            }
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     登録用配列作成（自分）（シリーズページより取得）
     */
    private func makeMyScoreArrayTargetVersion(iidxId: String, djName: String, seedRealm: Realm
        , targetVersionArray: [Int]) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if isCancel(msg: "") { return }
        
        for ver in targetVersionArray {
            // バージョン取得
            let version: Code = seedRealm.objects(Code.self)
                .filter("\(Code.Types.kindCode.rawValue) = %@ and \(Code.Types.code.rawValue) = %@", Const.Value.kindCode.VERSION, ver).first ?? Code()
            
            // HTML取得
            let v = ver - 1
            let data: NSData = CommonMethod.postRequest(dataUrl: Const.Url().getSeriesUrl()
                , postStr: "list=\(v)&play_style=\(String(describing: self.playStyle))&s=1&rival="
                , cookieStr: CommonData.Import.cookieStr)

            // HTMLスクレイピング
            let djName: String = djName
            let htmlStr: String = String(data: data as Data, encoding: .windows31j) ?? ""
            self.parseMyScoreTargetVersion(html: htmlStr, iidxId: iidxId, djName: djName, versionName: version.name ?? "")
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /*
     登録用配列作成（ライバル）（シリーズページより取得）
     */
    private func makeRivalScoreArrayTargetVersion(iidxId: String, seedRealm: Realm, scoreRealm: Realm
        , targetVersionArray: [Int]) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if isCancel(msg: "") { return }

        for ver in targetVersionArray {
            // バージョン取得
            let version: Code = seedRealm.objects(Code.self)
                .filter("\(Code.Types.kindCode.rawValue) = %@ and \(Code.Types.code.rawValue) = %@", Const.Value.kindCode.VERSION, ver).first ?? Code()
            
            // ライバルコード取得
            let rivalStatus: RivalStatus = scoreRealm.objects(RivalStatus.self)
                .filter("\(RivalStatus.Types.iidxId.rawValue) = %@ and \(RivalStatus.Types.playStyle.rawValue) = %@"
                    , iidxId, playStyle).first ?? RivalStatus()
            let code: String = rivalStatus.code ?? ""
            
            // HTML取得
            let v = ver - 1
            let data: NSData = CommonMethod.postRequest(dataUrl: Const.Url().getSeriesRivalUrl()
                , postStr: "list=\(v)&play_style=\(String(describing: self.playStyle))&s=1&rival=\(code)"
                , cookieStr: CommonData.Import.cookieStr)

            // HTMLスクレイピング
            let djName: String = rivalStatus.djName ?? ""
            let htmlStr: String = String(data: data as Data, encoding: .windows31j) ?? ""
            self.parseRivalScoreTargetVersion(html: htmlStr, iidxId: iidxId, djName: djName, versionName: version.name ?? "")
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// キャンセル判定
    func isCancel(msg: String) -> Bool {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret: Bool = false
        // キャンセル時
        if self.mainVC.cancelFlg {
            Log.info(cls: String(describing: self), method: #function, msg: msg + " canceled.")
            self.stopFlg = true
            ret = true
        } else {
            ret = false
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
}
