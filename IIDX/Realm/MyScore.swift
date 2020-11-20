//
//  MyScore26.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

class MyScore: RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var playStyle: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var genre: String?
    @objc dynamic var artist: String?
    @objc dynamic var difficultyId: Int = 0
    @objc dynamic var level: Int = 0
    @objc dynamic var totalNotes: Int = 0
    @objc dynamic var clearLump: Int = 1    // 1 : No Play
    @objc dynamic var djLevel: Int = 1      // 1 : No Play
    @objc dynamic var score: String = Const.Label.Score.ZERO
    @objc dynamic var scoreRate: Double = 0
    @objc dynamic var missCount: Int = 9999
    @objc dynamic var versionId: Int = 0
    @objc dynamic var indexId: Int = 0
    @objc dynamic var selectCount: Int = 0
    @objc dynamic var lastImportDateId: Int = 0
    @objc dynamic var oldScoreId: Int = 0
    @objc dynamic var tag: String?
    @objc dynamic var plusMinus: String?
    @objc dynamic var memo: String?
    @objc dynamic var ghostScore: String?
    @objc dynamic var createDate = Date()
    @objc dynamic var createUser: String = Const.Realm.SYSTEM
    @objc dynamic var updateDate = Date()
    @objc dynamic var updateUser: String = Const.Realm.SYSTEM

    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum Types: String {
        case id
        case playStyle
        case title
        case genre
        case artist
        case difficultyId
        case level
        case totalNotes
        case clearLump
        case djLevel
        case score
        case scoreRate
        case missCount
        case versionId
        case indexId
        case selectCount
        case lastImportDateId
        case oldScoreId
        case tag
        case plusMinus
        case memo
        case ghostScore
        case createDate
        case updateDate
    }
}
