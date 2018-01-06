//
//  ClosureMenuItem.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class ClosureMenuItem: NSMenuItem {

    private let actionClosure:() -> Void

    init(title: String, keyEquivalent: String = "", actionClosure: @escaping () -> Void) {
        self.actionClosure = actionClosure
        super.init(title: title, action: #selector(runAction(sender:)), keyEquivalent: keyEquivalent)
        self.target = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func runAction(sender: Any) {
        self.actionClosure()
    }

}
