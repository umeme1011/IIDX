//
//  MyStatus.swift
//  IIDX
//
//  Created by umeme on 2019/08/29.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

class MyStatus : RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var djName: String?
    @objc dynamic var iidxId: String?
    @objc dynamic var rank: String?
    @objc dynamic var playCount: Int = 0
    @objc dynamic var djPointSP: Int = 0
    @objc dynamic var djPointDP: Int = 0
    @objc dynamic var arenaClassSP: String?
    @objc dynamic var arenaClassDP: String?
    @objc dynamic var qproUrl: String?
    @objc dynamic var createDate = Date()
    @objc dynamic var createUser: String?
    @objc dynamic var updateDate = Date()
    @objc dynamic var updateUser: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum Types: String {
        case id
        case djName
        case iidxId
        case rank
        case playCount
        case djPointSP
        case djPointDP
        case arenaClassSP
        case arenaClassDP
        case qproUrl
    }
}


