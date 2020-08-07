//
//  RivalStatus.swift
//  IIDX
//
//  Created by umeme on 2019/08/29.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

class RivalStatus : RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var playStyle: Int = 0
    @objc dynamic var djName: String?
    @objc dynamic var iidxId: String?
    @objc dynamic var rank: String?
    @objc dynamic var code: String?
    @objc dynamic var createDate = Date()
    @objc dynamic var createUser: String?
    @objc dynamic var updateDate = Date()
    @objc dynamic var updateUser: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum Types: String {
        case playStyle
        case djName
        case iidxId
        case rank
        case code
    }
}

