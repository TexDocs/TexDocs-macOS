//
//  ColorScheme.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

struct ColorScheme {
    func color(forKey key: ColorKey) -> NSColor {
        return colors[key] ?? .black
    }
    
    var colors: [ColorKey: NSColor]
}


let defaultColorScheme = ColorScheme(colors: [
    .text: .textColor,
    .comment: NSColor(red: 0, green: 0.456, blue: 0, alpha: 1),
    .keyword: NSColor(red: 0.665, green: 0.052, blue: 0.569, alpha: 1),
    .variable: NSColor(red: 0.11, green: 0, blue: 0.81, alpha: 1),
    .escapedCharacter: NSColor(red: 0.77, green: 0.102, blue: 0.086, alpha: 1),
    .inlineMath: NSColor(red: 0, green: 0.456, blue: 0, alpha: 1)
])
