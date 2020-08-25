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
            
            let seedRealm: MyRealm = MyRealm.init(path: CommonMethod.getSeedRealmPath())
            let scoreRealm: MyRealm = MyRealm.init(path: CommonMethod.getScoreRealmPath())

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
                // キャンセル以外の中断
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
                    let scoreRealm: MyRealm = MyRealm.init(path: CommonMethod.getScoreRealmPath())
                    let myStatuses: Results<MyStatus> = scoreRealm.readAll(MyStatus.self)
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
    private func importScores(target: String, seedRealm: MyRealm, scoreRealm: MyRealm) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.info(cls: String(describing: self), method: #function, msg: "取り込み対象アカウント " + target)
        
        if isCancel(msg: "") { return }
        
        // 初回
        if firstLoadFlg {
            // 登録用配列作成
            self.makeMyScoreArray(iidxId: "", djName: "", seedRealm: seedRealm, scoreRealm: scoreRealm)

        // ２回め以降
        } else {
            let myStatuses: Results<MyStatus>
                = scoreRealm.readEqual(MyStatus.self, ofTypes: MyStatus.Types.iidxId.rawValue
                    , forQuery: [target] as AnyObject)
            
            // 自分
            if !myStatuses.isEmpty {
                // 登録用配列作成
                self.makeMyScoreArray(iidxId: target, djName:myStatuses.first?.djName ?? ""
                    ,seedRealm: seedRealm, scoreRealm: scoreRealm)
                
            // ライバル
            } else {
                // 登録用配列作成
                self.makeRivalScoreArray(iidxId: target, seedRealm: seedRealm, scoreRealm: scoreRealm)
            }
        }

        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    
    /// 登録用配列作成（自分）
    private func makeMyScoreArray(iidxId: String, djName: String, seedRealm: MyRealm, scoreRealm: MyRealm) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if isCancel(msg: "") { return }

        // バージョン全件取得
        let versions: Results<Code>
            = seedRealm.readEqual(Code.self, ofTypes: Code.Types.kindCode.rawValue
                , forQuery: [Const.Value.kindCode.VERSION] as AnyObject)
        
        var cnt: Int = versions.count
        if Const.Mode.DEVElOP { cnt = 5 }
        for i in 0..<cnt {
            
            let versionName: String = versions[i].name ?? ""
            Log.debug(cls: String(describing: self), method: #function, msg: versionName)
            if isCancel(msg: versionName) { return }

            // HTML取得
            let data: NSData = CommonMethod.postRequest(dataUrl: Const.Url().getSeriesUrl()
                , postStr: "list=\(i)&play_style=\(String(describing: self.playStyle))&s=1&rival="
                , cookieStr: CommonData.Import.cookieStr)

            // HTMLスクレイピング
            let djName: String = djName
            let htmlStr: String = String(data: data as Data, encoding: .windows31j) ?? ""
            self.parseMyScore(html: htmlStr, iidxId: iidxId, djName: djName, versionName: versionName)
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    

    /// 登録用配列作成（ライバル）
    private func makeRivalScoreArray(iidxId: String, seedRealm: MyRealm, scoreRealm: MyRealm) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        if isCancel(msg: "") { return }

        // バージョン全件取得
        let versions: Results<Code>
            = seedRealm.readEqual(Code.self, ofTypes: Code.Types.kindCode.rawValue
                , forQuery: [Const.Value.kindCode.VERSION] as AnyObject)
        
        var cnt: Int = versions.count
        if Const.Mode.DEVElOP { cnt = 5 }
        for i in 0..<cnt {
            
            let versionName: String = versions[i].name ?? ""
            Log.debug(cls: String(describing: self), method: #function, msg: versionName)
            if isCancel(msg: versionName) { return }
            
            // HIML取得
            let rivalStatus: RivalStatus
                = scoreRealm.readEqualAndByPlayStyle(RivalStatus.self, ofTypes: [RivalStatus.Types.iidxId.rawValue]
                    , forQuery: [[iidxId] as AnyObject]).first ?? RivalStatus()
            let code: String = rivalStatus.code ?? ""
            let data: NSData = CommonMethod.postRequest(dataUrl: Const.Url().getSeriesRivalUrl()
                , postStr: "list=\(i)&play_style=\(String(describing: self.playStyle))&s=1&rival=\(code)"
                , cookieStr: CommonData.Import.cookieStr)

            // HTMLスクレイピング
            let djName: String = rivalStatus.djName ?? ""
            let htmlStr: String = String(data: data as Data, encoding: .windows31j) ?? ""
            self.parseRivalScore(html: htmlStr, iidxId: iidxId, djName: djName, versionName: versionName)
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
