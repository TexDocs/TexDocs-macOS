//
//  MultiDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 11.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class MultiDelegate<Delegate: AnyObject> {
    private var references: [WeakContainer<Delegate>] = []

    private func clean() {
        references = references.filter { $0.reference != nil }
    }

    var objects: [Delegate] {
        clean()
        return references.map {
            $0.reference!
        }
    }

    func add(delegate: Delegate) {
        clean()
        references.append(WeakContainer(reference: delegate))
    }

    func forEach(_ body: (Delegate) -> Void) {
        objects.forEach(body)
    }
}

private struct WeakContainer<Type: AnyObject> {
    weak var reference: Type?
}
