//
//  ThemesHandler.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class ThemesHandler {
    private init() {
        current = defaultColorScheme
    }

    func color(for colorKey: ColorKey) -> NSColor {
        return current.color(forKey: colorKey) ?? defaultColorScheme.color(forKey: colorKey) ?? .black
    }
    
    static let `default` = ThemesHandler()
    
    var current: Theme
}

enum ColorKey: String, CodingKey {
    case text
    case comment
    case keyword
    case variable
    case escapedCharacter
    case inlineMath
}
