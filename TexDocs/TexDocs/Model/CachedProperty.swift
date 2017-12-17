//
//  CachedProperty.swift
//  TexDocs
//
//  Created by Noah Peeters on 09.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class CachedProperty<Value> {
    private var cache: Value? = nil
    private let block: () -> Value
    private let invalidationBlock: (() -> Void)?

    var value: Value {
        if let cache = cache {
            return cache
        }
        let computed = block()
        cache = computed
        return computed
    }

    func invalidateCache() {
        cache = nil
        invalidationBlock?()
    }

    init(block: @escaping () -> Value, invalidationBlock: (() -> Void)? = nil) {
        self.block = block
        self.invalidationBlock = invalidationBlock
    }
}
