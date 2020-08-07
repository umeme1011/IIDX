//
//  Code.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

class Code: RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var kindCode: Int = 0
    @objc dynamic var kindName: String?
    @objc dynamic var code: Int = 0
    @objc dynamic var name: String?
    @objc dynamic var sort: Int = 0
    @objc dynamic var createDate = Date()
    @objc dynamic var createUser: String = "SYSTEM"
    @objc dynamic var updateDate = Date()
    @objc dynamic var updateUser: String = "SYSTEM"

    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum Types: String {
        case kindCode
        case kindName
        case code
        case name
        case sort
    }
}
