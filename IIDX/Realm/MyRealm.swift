//
//  MyScoreRealm.swift
//  IIDX
//
//  Created by umeme on 2019/08/29.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

/*
 使わない！
 */
class MyRealm {

    var realm: Realm
    var playStyle: Int

    init(path: String) {
        // realm設定
        let config = Realm.Configuration(schemaVersion: UInt64(Const.Realm.SCHEMA_VER))
        Realm.Configuration.defaultConfiguration = config
        
        realm = try! Realm(fileURL: URL(fileURLWithPath: path))
        
        let myUD: MyUserDefaults = MyUserDefaults()
        playStyle = myUD.getPlayStyle()
    }

    
    /// 読み込み系
    
    func readAll<T: Object>(_ type: T.Type) -> Results<T> {
        let result = realm.objects(T.self)
        return result
    }

    func readAllByCreateDate<T: Object>(_ type: T.Type, param: Date) -> Results<T> {
        let result = realm.objects(T.self).filter("createDate > %@", param)
        return result
    }

    func readAllByUpdateDate<T: Object>(_ type: T.Type, param: Date) -> Results<T> {
        let result = realm.objects(T.self).filter("updateDate > %@", param)
        return result
    }

    func readAllByPlayStyle<T: Object>(_ type: T.Type) -> Results<T> {
        let result = realm.objects(T.self).filter("playStyle = %@", playStyle)
        return result
    }
    
    func readEqual<T: Object>(_ type: T.Type, ofTypes: String, forQuery: AnyObject) -> Results<T> {
        let result = realm.objects(T.self).filter(NSPredicate(format: "\(ofTypes) = %@", argumentArray: forQuery as? [Any]))
        return result
    }

    func readNotEqual<T: Object>(_ type: T.Type, ofTypes: String, forQuery: AnyObject) -> Results<T> {
        let result = realm.objects(T.self).filter(NSPredicate(format: "\(ofTypes) != %@", argumentArray: forQuery as? [Any]))
        return result
    }

    func readEqualByPlayStyle<T: Object>(_ type: T.Type, ofTypes: String, forQuery: AnyObject) -> Results<T> {
        var result = realm.objects(T.self).filter("playStyle = %@", playStyle)
        result = realm.objects(T.self).filter(NSPredicate(format: "\(ofTypes) = %@", argumentArray: forQuery as? [Any]))
        return result
    }

    func readEqualAnd<T: Object>(_ type: T.Type, ofTypes: [String], forQuery: [AnyObject]) -> Results<T> {
        var predicates: [NSPredicate] = [NSPredicate]()
        for i in 0..<ofTypes.count {
            let predicate = NSPredicate(format: "\(ofTypes[i]) = %@", argumentArray: forQuery[i] as? [Any])
            predicates.append(predicate)
        }
        let result = realm.objects(T.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
        return result
    }
    
    func readEqualAndByPlayStyle<T: Object>(_ type: T.Type, ofTypes: [String], forQuery: [AnyObject]) -> Results<T> {
        var predicates: [NSPredicate] = [NSPredicate]()
        for i in 0..<ofTypes.count {
            let predicate = NSPredicate(format: "\(ofTypes[i]) = %@", argumentArray: forQuery[i] as? [Any])
            predicates.append(predicate)
        }
        var result = realm.objects(T.self).filter("playStyle = %@", playStyle)
        result = result.filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
        return result
    }
    
    func readInAnd<T: Object>(_ type: T.Type, ofTypes: [String], forQuery: [[AnyObject]]) -> Results<T> {
        var predicates: [NSPredicate] = [NSPredicate]()
        for i in 0..<ofTypes.count {
            let predicate = NSPredicate(format: "\(ofTypes[i]) in %@", argumentArray: [forQuery[i]])
            predicates.append(predicate)
        }
        var result = realm.objects(T.self).filter("playStyle = %@", playStyle)
        result = result.filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
        return result
    }
    
    func readLikeAnd<T: Object>(_ type: T.Type, ofTypes: String, forQuery: [AnyObject]) -> Results<T> {
        var predicates: [NSPredicate] = [NSPredicate]()
        for i in 0..<forQuery.count {
            let predicate = NSPredicate(format: "\(ofTypes) contains %@", argumentArray: [forQuery[i]])
            predicates.append(predicate)
        }
        print(predicates.description)
        var result = realm.objects(T.self).filter("playStyle = %@", playStyle)
        result = result.filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
        return result
    }

    
    /// 更新系
    
//    func create<T: Object>(data: [T]) {
//        try! realm.write {
//            realm.add(data)
//        }
//    }

    func update<T: Object>(data: [T]) {
        try! realm.write {
            realm.add(data, update: .all)
        }
    }
    
    func deleteAll<T: Object>(_ type: T.Type) {
        try! realm.write {
            let obj = realm.objects(T.self)
            realm.delete(obj)
        }
    }
    
    func deleteAllByPlayStyle<T: Object>(_ type: T.Type) {
        try! realm.write {
            let obj = realm.objects(T.self).filter("playStyle = %@", playStyle)
            realm.delete(obj)
        }
    }
    
    func deleteEqual<T: Object>(_ type: T.Type, predicates: NSPredicate) {
        try! realm.write {
            let obj = realm.objects(T.self).filter(predicates)
            realm.delete(obj)
        }
    }
    
    func deleteEqualAnd<T: Object>(_ type: T.Type, ofTypes: [String], forQuery: [AnyObject]) {
        let result: Results<T> = readEqualAnd(type.self, ofTypes: ofTypes, forQuery: forQuery)
        try! realm.write {
            realm.delete(result)
        }
    }

    func deleteEqualAndByPlayStyle<T: Object>(_ type: T.Type, ofTypes: [String], forQuery: [AnyObject]) {
        let result: Results<T> = readEqualAndByPlayStyle(type.self, ofTypes: ofTypes, forQuery: forQuery)
        try! realm.write {
            realm.delete(result)
        }
    }
    
    func deleteAllTbl() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    
    /// 詳細編集用
    func updateForDetail(score: MyScore, clearLump: Int, djLevel: Int
        , s: String, scoreRate: Double, missCount: String, tag: String) {
        try! realm.write {
            score.clearLump = clearLump
            score.djLevel = djLevel
            score.score = s
            score.scoreRate = scoreRate
            score.missCount = missCount
            score.tag = tag
            score.updateDate = Date()
            realm.add(score, update: .all)
        }
    }


    /// タグ削除時の関連タグ削除用
    func readContainsForTag(array: [String]) -> Results<MyScore> {
        var predicates: [NSPredicate] = [NSPredicate]()
        for i in 0..<array.count {
            let tag: String = "[" + array[i] + "]"
            let predicate = NSPredicate(format: "tag contains %@", tag)
            predicates.append(predicate)
        }
        let result = realm.objects(MyScore.self).filter(NSCompoundPredicate(orPredicateWithSubpredicates: predicates))
        return result
    }
    
    /// タグ削除時の関連タグ削除用
    func updateForTag(score: MyScore, tag: String) {
        try! realm.write {
            score.tag = tag
            realm.add(score, update: .all)
        }
    }
    
    
    /// Songテーブルの更新フラグ更新用
    func updateUpdFlg(song: Song, updFlg: Int) {
        try! realm.write {
            song.updFlg = updFlg
            realm.add(song, update: .all)
        }
    }
}
