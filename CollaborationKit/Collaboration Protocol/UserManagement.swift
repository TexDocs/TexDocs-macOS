//
//  UserManagement.swift
//  CollaborationKit
//
//  Created by Noah Peeters on 06.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import MessagePack
import MessagePackKit

struct UserJoinedNotification: MessagePackDecodable {
    let sessionUUID: UUID

    init(from values: [MessagePackValue]) throws {
        try sessionUUID = values.at(0).uuidValue.unwrap()
    }
}

struct UserLeftNotification: MessagePackDecodable {
    let sessionUUID: UUID

    init(from values: [MessagePackValue]) throws {
        try sessionUUID = values.at(0).uuidValue.unwrap()
    }
}
