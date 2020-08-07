//
//  LastImportDate.swift
//  IIDX
//
//  Created by umeme on 2019/08/30.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

class LastImportDate: RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var playStyle: Int = 0
    @objc dynamic var date: String?
    @objc dynamic var createDate = Date()
    @objc dynamic var createUser: String?
    @objc dynamic var updateDate = Date()
    @objc dynamic var updateUser: String?

    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum Types: String {
        case playStyle
        case date
    }
}
