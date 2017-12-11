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
        let applicationSupportPath = FileManager.default
                .urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(Bundle.main.bundleIdentifier!)
        let themePath = applicationSupportPath?.appendingPathComponent("themes", isDirectory: true)

        print("Searching for themes at \(themePath?.path ?? "<Error>")")
        if let themePath = themePath,
            let themePaths = try? FileManager.default.contentsOfDirectory(atPath: themePath.path) {

            for url in themePaths.map({ themePath.appendingPathComponent($0) }) {
                if let theme = try? Theme.load(from: url) {
                    themes[url.lastPathComponent] = theme
                }
            }
        }
    }

    func color(for colorKey: ColorKey) -> NSColor {
        return current.color(forKey: colorKey) ?? defaultScheme.color(forKey: colorKey) ?? .black
    }
    
    static let `default` = ThemesHandler()
    
    var current: Theme {
        return themes[UserDefaults.themeName.value] ?? defaultScheme
    }

    private(set) var themes: [String: Theme] = [
        "Default": defaultScheme
    ]

    var themeNames: [String] {
        return Array(themes.keys)
    }
}

enum ColorKey: String, CodingKey {
    case text
    case comment
    case keyword
    case variable
    case escapedCharacter
    case inlineMath
    case pdfBackground
    case editorBackground
    case consoleBackground
    case consoleText
}
