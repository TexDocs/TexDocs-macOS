//
//  CollaborationUser.swift
//  CollaborationKit
//
//  Created by Noah Peeters on 06.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import Foundation

public class CollaborationUser {
    var cursor: CollaborationCursor?
    let displayName: String
    let sessionUUID: UUID

    init(displayName: String, sessionUUID: UUID) {
        self.displayName = displayName
        self.sessionUUID = sessionUUID
    }
}
