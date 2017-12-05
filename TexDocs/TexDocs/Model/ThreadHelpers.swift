//
//  ThreadHelpers.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static func ensureMain(execute block: () -> Void) {
        if !Thread.current.isMainThread {
            DispatchQueue.main.sync(execute: block)
        }
        block()
    }
}
