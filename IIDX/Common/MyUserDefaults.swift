//
//  MyUserDefaults.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import Foundation
import RealmSwift

class MyUserDefaults {
    let ud = UserDefaults.standard
    var version: String = ""
    
    init() {
        version = String(getVersion())
    }
    
    /*
     すべて初期化
     */
    func initAll() {
        if let domain = Bundle.main.bundleIdentifier {
            ud.removePersistentDomain(forName: domain)
        }
    }

    /*
     バージョンごとに初期化
     */
    func initVersion() {
        for (key, value) in ud.dictionaryRepresentation().sorted(by: { $0.0 < $1.0 }) {
            if key.contains(String(getVersion())) {
                print("- \(key) => \(value)")
                ud.removeObject(forKey: key)
            }
        }
    }
    
    // プレイスタイル
    func setPlayStyle(playStyle : Int) {
        ud.set(playStyle, forKey: "playStyle\(String(getVersion()))")
    }
    
    func getPlayStyle() -> Int {
        return ud.object(forKey: "playStyle\(String(getVersion()))") as? Int ?? Const.Value.PlayStyle.SINGLE
    }
    
    // 更新お知らせ表示フラグ
    func setUpdateInfoFlg(flg : Bool) {
        ud.set(flg, forKey: "updateInfoFlg\(String(getVersion()))")
    }
    
    func getUpdateInfoFlg() -> Bool {
        return ud.object(forKey: "updateInfoFlg\(String(getVersion()))") as? Bool ?? true
    }
    
    /*
     設定（SPDP共通）
     */
    func setVersion(no: Int) {
        ud.set(no, forKey: "version")
    }
    
    func getVersion() -> Int {
        return ud.object(forKey: "version") as? Int ?? Const.Version.PRESENT_VERSION_NO
    }
    
    func setId(id : String) {
        ud.set(id, forKey: "id\(String(getVersion()))")
    }
    
    func getId() -> String {
        return ud.object(forKey: "id\(String(getVersion()))") as? String ?? ""
    }
    
    func setPassword(password : String) {
        ud.set(password, forKey: "password\(String(getVersion()))")
    }
    
    func getPassword() -> String {
        return ud.object(forKey: "password\(String(getVersion()))") as? String ?? ""
    }
    
    /*
     設定（SPDP毎）
     */
    func setTarget(target : String) {
        ud.set(target, forKey: "target\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getTarget() -> String {
        return ud.object(forKey: "target\(getPlayStyle())\(String(getVersion()))") as? String ?? ""
    }
    
    func setMissCountFlg(flg: Bool) {
        ud.set(flg, forKey: "missCountFlg\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getMissCountFlg() -> Bool{
        // 初期値ミスカウント取り込みあり
        return ud.object(forKey: "missCountFlg\(getPlayStyle())\(String(getVersion()))") as? Bool ?? true
    }
    
    func setMode(mode : Int) {
        ud.set(mode, forKey: "mode\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getMode() -> Int {
        return ud.object(forKey: "mode\(getPlayStyle())\(String(getVersion()))") as? Int ?? Const.Value.Mode.EDIT_MODE
    }
    
    // 初回取り込みかどうか
    func setFirstLoadFlg(firstLoadFlg: Bool) {
        ud.set(firstLoadFlg, forKey: "firstLoadFlg\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getFirstLoadFlg() -> Bool {
        return ud.object(forKey: "firstLoadFlg\(getPlayStyle())\(String(getVersion()))") as? Bool ?? true
    }
    
    // ソート
    func setSort(sort: Int) {
        ud.set(sort, forKey: "sort\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getSort() -> Int {
        return ud.object(forKey: "sort\(getPlayStyle())\(String(getVersion()))") as? Int ?? Const.Value.Sort.INDEX_ASK
    }
    
    // フィルター
    func setFoldingFlgArray(array: [Bool]) {
        ud.set(array, forKey: "foldingFlgArray\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getFoldingFlgArray() -> [Bool] {
        // 初期値：全セクション折りたたみ状態
        return ud.object(forKey: "foldingFlgArray\(getPlayStyle())\(String(getVersion()))")
            as? [Bool] ?? [false, false, false, false, false, false, false]
    }

    func setRivalFoldingFlgArray(array: [Bool]) {
        ud.set(array, forKey: "rivalFoldingFlgArray\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getRivalFoldingFlgArray() -> [Bool] {
        // 初期値：全セクション折りたたみ状態
        return ud.object(forKey: "rivalFoldingFlgArray\(getPlayStyle())\(String(getVersion()))")
            as? [Bool] ?? [false, false, false, false]
    }

    func setTagFoldingFlg(flg: Bool) {
        ud.set(flg, forKey: "tagFoldingFlg\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getTagFoldingFlg() -> Bool {
        // 初期値：全セクション折りたたみ状態
        return ud.object(forKey: "tagFoldingFlg\(getPlayStyle())\(String(getVersion()))") as? Bool ?? false
    }

    func setCheckDic(dic: Data) {
        ud.set(dic, forKey: "checkDic\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getCheckDic() -> Data {
        return ud.object(forKey: "checkDic\(getPlayStyle())\(String(getVersion()))") as? Data ?? Data()
    }

    func setRivalCheckDic(dic: Data) {
        ud.set(dic, forKey: "rivalCheckDic\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getRivalCheckDic() -> Data {
        return ud.object(forKey: "rivalCheckDic\(getPlayStyle())\(String(getVersion()))") as? Data ?? Data()
    }

    func setTagCheckArray(array: [String]) {
        ud.set(array, forKey: "tagCheckDic\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getTagCheckArray() -> [String] {
        return ud.object(forKey: "tagCheckDic\(getPlayStyle())\(String(getVersion()))") as? [String] ?? [String]()
    }

    func setSearchWord(word: String) {
        ud.set(word, forKey: "searchWord\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getSearchWord() -> String {
        return ud.object(forKey: "searchWord\(getPlayStyle())\(String(getVersion()))") as? String ?? ""
    }
    
    func setTitleArray(title: [String]) {
        ud.set(title, forKey: "titleArray\(getPlayStyle())\(String(getVersion()))")
    }

    func getTitleArray() -> [String] {
        return ud.object(forKey: "titleArray\(getPlayStyle())\(String(getVersion()))") as? [String] ?? [String]()
    }
    
    // 取込対象ページ
    func setTargetPage(target: Int) {
        ud.set(target, forKey: "targetPage\(getPlayStyle())\(String(getVersion()))")
    }

    func getTargetPage() -> Int {
        return ud.object(forKey: "targetPage\(getPlayStyle())\(String(getVersion()))")
            as? Int ?? Const.Value.TargetPage.VERSION
    }
    
    // 取込対象ページのレベルチェック
    func setTargetPageLevelCheckArray(array: [String]) {
        ud.set(array, forKey: "levelCheckArray\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getTargetPageLevelCheckArray() -> [String] {
        return ud.object(forKey: "levelCheckArray\(getPlayStyle())\(String(getVersion()))") as? [String] ?? [String]()
    }

    // 取込対象ページのバージョンチェック
    func setTargetPageVersionCheckArray(array: [String]) {
        ud.set(array, forKey: "versionCheckArray\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getTargetPageVersionCheckArray() -> [String] {
        // 全バージョン取得
        let seedRealm: Realm = CommonMethod.createSeedRealm();
        let codes: Results<Code> = seedRealm.objects(Code.self).filter("\(Code.Types.kindCode.rawValue) = %@", Const.Value.kindCode.VERSION).sorted(byKeyPath: Code.Types.code.rawValue)
        var versionArray: [String] = [String]()
        for code in codes {
            versionArray.append(String(code.code))
        }
        // 初期値はバージョン全選択
        return ud.object(forKey: "versionCheckArray\(getPlayStyle())\(String(getVersion()))") as? [String] ?? versionArray
    }

    // 取込対象ページのレベル全選択チェック
    func setTargetPageLevelAllFlg(flg: Bool) {
        ud.set(flg, forKey: "targetPageLevelAllFlg\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getTargetPageLevelAllFlg() -> Bool {
        return ud.object(forKey: "targetPageLevelAllFlg\(getPlayStyle())\(String(getVersion()))") as? Bool ?? false
    }

    // 取込対象ページのバージョン全選択チェック
    func setTargetPageVersionAllFlg(flg: Bool) {
        ud.set(flg, forKey: "targetPageVersionAllFlg\(getPlayStyle())\(String(getVersion()))")
    }
    
    func getTargetPageVersionAllFlg() -> Bool {
        return ud.object(forKey: "targetPageVersionAllFlg\(getPlayStyle())\(String(getVersion()))") as? Bool ?? true
    }

}
