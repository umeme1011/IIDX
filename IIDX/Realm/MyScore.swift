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
    @objc dynamic var versionId: Int = 0
    @objc dynamic var indexId: Int = 0
    @objc dynamic var difficultyId: Int = 0
    @objc dynamic var level: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var genre: String?
    @objc dynamic var artist: String?
    @objc dynamic var totalNotes: Int = 0
    @objc dynamic var clearLump: Int = 1    // 1 : No Play
    @objc dynamic var djLevel: Int = 1      // 1 : No Play
    @objc dynamic var score: String = Const.Label.Score.ZERO
    @objc dynamic var scoreRate: Double = 0
    @objc dynamic var missCount: Int = 9999
    @objc dynamic var selectCount: Int = 0
    @objc dynamic var plusMinus: String?
    @objc dynamic var ghostClearLump: Int = 1    // 1 : No Play
    @objc dynamic var ghostDjLevel: Int = 1      // 1 : No Play
    @objc dynamic var ghostScore: String = Const.Label.Score.ZERO
    @objc dynamic var ghostScoreRate: Double = 0
    @objc dynamic var ghostMissCount: Int = 9999
    @objc dynamic var ghostSelectCount: Int = 0
    @objc dynamic var ghostPlusMinus: String?
    @objc dynamic var lastImportDateId: Int = 0
    @objc dynamic var oldScoreId: Int = 0
    @objc dynamic var tag: String?
    @objc dynamic var memo: String?
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
        case versionId
        case indexId
        case difficultyId
        case level
        case title
        case genre
        case artist
        case totalNotes
        case clearLump
        case djLevel
        case score
        case scoreRate
        case missCount
        case selectCount
        case plusMinus
        case ghostClearLump
        case ghostDjLevel
        case ghostScore
        case ghostScoreRate
        case ghostMissCount
        case ghostSelectCount
        case ghostPlusMinus
        case lastImportDateId
        case oldScoreId
        case tag
        case memo
        case createDate
        case createUser
        case updateDate
        case updateUser
    }
}
