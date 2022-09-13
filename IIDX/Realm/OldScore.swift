//
//  OldScore.swift
//  IIDX
//
//  Created by umeme on 2019/08/30.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

class OldScore : RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var playStyle: Int = 0
    @objc dynamic var versionId: Int = 0
    @objc dynamic var difficultyId: Int = 0
    @objc dynamic var level: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var genre: String?
    @objc dynamic var artist: String?
    @objc dynamic var clearLump: Int = 0
    @objc dynamic var djLevel: Int = 0
    @objc dynamic var score: Int = 0
    @objc dynamic var pgreat: Int = 0
    @objc dynamic var great: Int = 0
    @objc dynamic var scoreRate: Double = 0
    @objc dynamic var missCount: Int = 9999
    @objc dynamic var plusMinus: String?
    @objc dynamic var updateClearLump: Int = 0
    @objc dynamic var updateDjLevel: Int = 0
    @objc dynamic var updateScore: Int = 0
    @objc dynamic var updatePgreat: Int = 0
    @objc dynamic var updateGreat: Int = 0
    @objc dynamic var updateScoreRate: Double = 0
    @objc dynamic var updateMissCount: Int = 9999
    @objc dynamic var updatePlusMinus: String?
    @objc dynamic var playDate = Date()
    @objc dynamic var createDate = Date()
    @objc dynamic var createUser: String?
    @objc dynamic var updateDate = Date()
    @objc dynamic var updateUser: String?

    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum Types: String {
        case id
        case playStyle
        case versionId
        case difficultyId
        case level
        case title
        case genre
        case artist
        case clearLump
        case djLevel
        case score
        case pgreat
        case great
        case scoreRate
        case missCount
        case plusMinus
        case updateClearLump
        case updateDjLevel
        case updateScore
        case updatePgreat
        case updateGreat
        case updateScoreRate
        case updateMissCount
        case updatePlusMinus
        case playDate
    }
}
