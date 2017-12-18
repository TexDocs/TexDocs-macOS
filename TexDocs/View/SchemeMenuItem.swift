//
//  SchemeMenuItem.swift
//  TexDocs
//
//  Created by Noah Peeters on 04.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class SchemeMenuItem: NSMenuItem {
    let uuid: UUID

    init(scheme: DocumentData.Scheme) {
        self.uuid = scheme.uuid
        super.init(title: scheme.name, action: nil, keyEquivalent: "")
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
