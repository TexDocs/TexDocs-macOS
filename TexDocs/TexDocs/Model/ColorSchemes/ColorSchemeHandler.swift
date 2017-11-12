//
//  ColorSchemeHandler.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class ColorSchemeHandler {
    private init() {
        current = defaultColorScheme
    }
    
    static let `default` = ColorSchemeHandler()
    
    func color(forKey key: ColorKey) -> NSColor {
        return current.color(forKey: key)
    }
    
    var current: ColorScheme
}


enum ColorKey {
    case text
    case comment
    case keyword
    case variable
    case escapedCharacter
    case inlineMath
}
