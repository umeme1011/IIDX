//
//  Html.swift
//  IIDX
//
//  Created by umeme on 2019/09/25.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

class Html: RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var kindCode: Int = 0
    @objc dynamic var html: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }

    enum Types: String {
        case id
        case kindCode
        case html
    }
}
