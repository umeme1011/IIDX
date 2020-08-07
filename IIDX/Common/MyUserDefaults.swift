//
//  MyUserDefaults.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import Foundation

class MyUserDefaults {
    let ud = UserDefaults.standard
    var version: String = ""
    
    init() {
        version = String(getVersion())
    }
    
    // すべて初期化
    func initAll() {
        if let domain = Bundle.main.bundleIdentifier {
            ud.removePersistentDomain(forName: domain)
        }
    }
    
    // バージョンごとに初期化
    func initVersion() {
        for (key, value) in ud.dictionaryRepresentation().sorted(by: { $0.0 < $1.0 }) {
            if key.contains(String(getVersion())) {
                print("- \(key) => \(value)")
                ud.removeObject(forKey: key)
            }
        }
    }
    
    // Setting
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
    
    func setTarget(target : String) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(target, forKey: "targetDP\(String(getVersion()))")
        } else {
            ud.set(target, forKey: "targetSP\(String(getVersion()))")
        }
    }
    
    func getTarget() -> String {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "targetDP\(String(getVersion()))") as? String ?? ""
        } else {
            return ud.object(forKey: "targetSP\(String(getVersion()))") as? String ?? ""
        }
    }
    
    func setMissCountFlg(flg: Bool) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(flg, forKey: "missCountFlgDP\(String(getVersion()))")
        } else {
            ud.set(flg, forKey: "missCountFlgSP\(String(getVersion()))")
        }
    }
    
    func getMissCountFlg() -> Bool{
        // 初期値ミスカウント取り込みあり
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "missCountFlgDP\(String(getVersion()))") as? Bool ?? true
        } else {
            return ud.object(forKey: "missCountFlgSP\(String(getVersion()))") as? Bool ?? true
        }
    }
    
    func setMode(mode : Int) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(mode, forKey: "modeDP\(String(getVersion()))")
        } else {
            ud.set(mode, forKey: "modeSP\(String(getVersion()))")
        }
    }
    
    func getMode() -> Int {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "modeDP\(String(getVersion()))") as? Int ?? Const.Value.Mode.EDIT_MODE
        } else {
            return ud.object(forKey: "modeSP\(String(getVersion()))") as? Int ?? Const.Value.Mode.EDIT_MODE
        }
    }

    
    // プレイスタイル
    
    func setPlayStyle(playStyle : Int) {
        ud.set(playStyle, forKey: "playStyle\(String(getVersion()))")
    }
    
    func getPlayStyle() -> Int {
        return ud.object(forKey: "playStyle\(String(getVersion()))") as? Int ?? Const.Value.PlayStyle.SINGLE
    }
    
    
    // 初回取り込みかどうか
    
    func setFirstLoadFlg(firstLoadFlg: Bool) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(firstLoadFlg, forKey: "firstLoadFlgDP\(String(getVersion()))")
        } else {
            ud.set(firstLoadFlg, forKey: "firstLoadFlgSP\(String(getVersion()))")
        }
    }
    
    func getFirstLoadFlg() -> Bool {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "firstLoadFlgDP\(String(getVersion()))") as? Bool ?? true
        } else {
            return ud.object(forKey: "firstLoadFlgSP\(String(getVersion()))") as? Bool ?? true
        }
    }
    
    
    // 更新お知らせ表示フラグ
    
    func setUpdateInfoFlg(flg : Bool) {
        ud.set(flg, forKey: "updateInfoFlg\(String(getVersion()))")
    }
    
    func getUpdateInfoFlg() -> Bool {
        return ud.object(forKey: "updateInfoFlg\(String(getVersion()))") as? Bool ?? true
    }
    
    
    // ソート
    
    func setSort(sort: Int) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(sort, forKey: "sortDP\(String(getVersion()))")
        } else {
            ud.set(sort, forKey: "sortSP\(String(getVersion()))")
        }
    }
    
    func getSort() -> Int {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "sortDP\(String(getVersion()))") as? Int ?? Const.Value.Sort.INDEX_ASK
        } else {
            return ud.object(forKey: "sortSP\(String(getVersion()))") as? Int ?? Const.Value.Sort.INDEX_ASK
        }
    }
    
    
    // フィルター
    
    func setFoldingFlgArray(array: [Bool]) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(array, forKey: "foldingFlgArrayDP\(String(getVersion()))")
        } else {
            ud.set(array, forKey: "foldingFlgArraySP\(String(getVersion()))")
        }
    }
    
    func getFoldingFlgArray() -> [Bool] {
        // 初期値：全セクション折りたたみ状態
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "foldingFlgArrayDP\(String(getVersion()))")
                as? [Bool] ?? [false, false, false, false, false, false, false]
        } else {
            return ud.object(forKey: "foldingFlgArraySP\(String(getVersion()))")
                as? [Bool] ?? [false, false, false, false, false, false, false]
        }
    }

    func setRivalFoldingFlgArray(array: [Bool]) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(array, forKey: "rivalFoldingFlgArrayDP\(String(getVersion()))")
        } else {
            ud.set(array, forKey: "rivalFoldingFlgArraySP\(String(getVersion()))")
        }
    }
    
    func getRivalFoldingFlgArray() -> [Bool] {
        // 初期値：全セクション折りたたみ状態
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "rivalFoldingFlgArrayDP\(String(getVersion()))")
                as? [Bool] ?? [false, false, false, false]
        } else {
            return ud.object(forKey: "rivalFoldingFlgArraySP\(String(getVersion()))")
                as? [Bool] ?? [false, false, false, false]
        }
    }

    func setTagFoldingFlg(flg: Bool) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(flg, forKey: "tagFoldingFlgDP\(String(getVersion()))")
        } else {
            ud.set(flg, forKey: "tagFoldingFlgSP\(String(getVersion()))")
        }
    }
    
    func getTagFoldingFlg() -> Bool {
        // 初期値：全セクション折りたたみ状態
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "tagFoldingFlgDP\(String(getVersion()))")
                as? Bool ?? false
        } else {
            return ud.object(forKey: "tagFoldingFlgSP\(String(getVersion()))")
                as? Bool ?? false
        }
    }

    func setCheckDic(dic: Data) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(dic, forKey: "checkDicDP\(String(getVersion()))")
        } else {
            ud.set(dic, forKey: "checkDicSP\(String(getVersion()))")
        }
    }
    
    func getCheckDic() -> Data {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "checkDicDP\(String(getVersion()))") as? Data ?? Data()
        } else {
            return ud.object(forKey: "checkDicSP\(String(getVersion()))") as? Data ?? Data()
        }
    }

    func setRivalCheckDic(dic: Data) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(dic, forKey: "rivalCheckDicDP\(String(getVersion()))")
        } else {
            ud.set(dic, forKey: "rivalCheckDicSP\(String(getVersion()))")
        }
    }
    
    func getRivalCheckDic() -> Data {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "rivalCheckDicDP\(String(getVersion()))") as? Data ?? Data()
        } else {
            return ud.object(forKey: "rivalCheckDicSP\(String(getVersion()))") as? Data ?? Data()
        }
    }

    func setTagCheckArray(array: [String]) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(array, forKey: "tagCheckDicDP\(String(getVersion()))")
        } else {
            ud.set(array, forKey: "tagCheckDicSP\(String(getVersion()))")
        }
    }
    
    func getTagCheckArray() -> [String] {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "tagCheckDicDP\(String(getVersion()))") as? [String] ?? [String]()
        } else {
            return ud.object(forKey: "tagCheckDicSP\(String(getVersion()))") as? [String] ?? [String]()
        }
    }

    func setSearchWord(word: String) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(word, forKey: "searchWordDP\(String(getVersion()))")
        } else {
            ud.set(word, forKey: "searchWordSP\(String(getVersion()))")
        }
    }
    
    func getSearchWord() -> String {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "searchWordDP\(String(getVersion()))") as? String ?? ""
        } else {
            return ud.object(forKey: "searchWordSP\(String(getVersion()))") as? String ?? ""
        }
    }
    
    func setTitleArray(title: [String]) {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            ud.set(title, forKey: "titleArrayDP\(String(getVersion()))")
        } else {
            ud.set(title, forKey: "titleArraySP\(String(getVersion()))")
        }
    }

    func getTitleArray() -> [String] {
        if getPlayStyle() == Const.Value.PlayStyle.DOUBLE {
            return ud.object(forKey: "titleArrayDP\(String(getVersion()))") as? [String] ?? [String]()
        } else {
            return ud.object(forKey: "titleArraySP\(String(getVersion()))") as? [String] ?? [String]()
        }
    }
}
