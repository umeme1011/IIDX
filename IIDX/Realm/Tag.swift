//
//  Tag.swift
//  IIDX
//
//  Created by umeme on 2019/10/18.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

class Tag: RealmSwift.Object, NSCopying {
    
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
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy: Tag = Tag()
        copy.id = id
        copy.tag = tag
        copy.createDate = createDate
        copy.createUser = createUser
        copy.updateDate = updateDate
        copy.updateUser = updateUser
        
        return copy as Any
    }

}
