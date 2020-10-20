//
//  RivalScore.swift
//  IIDX
//
//  Created by umeme on 2019/09/06.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

class RivalScore: RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var playStyle: Int = 0
    @objc dynamic var iidxId: String?
    @objc dynamic var title: String?
    @objc dynamic var difficultyId: Int = 0
    @objc dynamic var level: Int = 0
    @objc dynamic var clearLump: Int = 0
    @objc dynamic var djLevel: Int = 0
    @objc dynamic var score: String?
    @objc dynamic var scoreRate: Double = 0
    @objc dynamic var missCount: Int = 9999
    @objc dynamic var versionId: Int = 0
    @objc dynamic var indexId: Int = 0
    @objc dynamic var plusMinus: String?
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
        case iidxId
        case title
        case difficultyId
        case level
        case clearLump
        case djLevel
        case score
        case scoreRate
        case missCount
        case versionId
        case indexId
        case plusMinus
    }
}

