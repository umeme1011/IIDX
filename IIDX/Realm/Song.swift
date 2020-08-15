//
//  Song.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

class Song : RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var spb: Int = 0
    @objc dynamic var spn: Int = 0
    @objc dynamic var sph: Int = 0
    @objc dynamic var spa: Int = 0
    @objc dynamic var spl: Int = 0
    @objc dynamic var dpn: Int = 0
    @objc dynamic var dph: Int = 0
    @objc dynamic var dpa: Int = 0
    @objc dynamic var dpl: Int = 0
    @objc dynamic var bpm: String?
    @objc dynamic var genre: String?
    @objc dynamic var title: String?
    @objc dynamic var artist: String?
    @objc dynamic var versionId: Int = 0
    @objc dynamic var indexId: Int = 0
    @objc dynamic var totalNotesSpb: Int = 0
    @objc dynamic var totalNotesSpn: Int = 0
    @objc dynamic var totalNotesSph: Int = 0
    @objc dynamic var totalNotesSpa: Int = 0
    @objc dynamic var totalNotesSpl: Int = 0
    @objc dynamic var totalNotesDpn: Int = 0
    @objc dynamic var totalNotesDph: Int = 0
    @objc dynamic var totalNotesDpa: Int = 0
    @objc dynamic var totalNotesDpl: Int = 0
    @objc dynamic var updFlg: Int = 0
    @objc dynamic var createDate = Date()
    @objc dynamic var createUser: String = "SYSTEM"
    @objc dynamic var updateDate = Date()
    @objc dynamic var updateUser: String = "SYSTEM"

    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum Types: String {
        case id
        case spb
        case spn
        case sph
        case spa
        case spl
        case dpn
        case dph
        case dpa
        case dpl
        case bpm
        case genre
        case title
        case artist
        case versionId
        case indexId
        case totalNotesSpb
        case totalNotesSpn
        case totalNotesSph
        case totalNotesSpa
        case totalNotesSpl
        case totalNotesDpn
        case totalNotesDph
        case totalNotesDpa
        case totalNotesDpl
        case updFlg
        case createDate
        case updateDate
    }
}

