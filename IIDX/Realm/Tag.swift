//
//  Tag.swift
//  IIDX
//
//  Created by umeme on 2019/10/18.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

class Tag: RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var tag: String?
    @objc dynamic var createDate = Date()
    @objc dynamic var createUser: String = "SYSTEM"
    @objc dynamic var updateDate = Date()
    @objc dynamic var updateUser: String = "SYSTEM"

    override static func primaryKey() -> String? {
        return "id"
    }

    enum Types: String {
        case id
        case tag
    }
}
