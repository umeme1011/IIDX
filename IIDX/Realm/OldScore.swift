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
    @objc dynamic var title: String?
    @objc dynamic var difficultyId: Int = 0
    @objc dynamic var level: Int = 0
    @objc dynamic var clearLump: Int = 0
    @objc dynamic var djLevel: Int = 0
    @objc dynamic var score: String?
    @objc dynamic var scoreRate: Double = 0
    @objc dynamic var missCount: String?
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
        case title
        case difficultyId
        case level
        case clearLump
        case djLevel
        case score
        case scoreRate
        case missCount
    }
}
