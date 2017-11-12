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
    .text: .black,
    .comment: .green,
    .keyword: .orange
])
