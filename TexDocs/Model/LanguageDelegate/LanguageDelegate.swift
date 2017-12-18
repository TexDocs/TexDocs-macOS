//
//  LanguageDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 07.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

protocol LanguageDelegate {
    init()
    func textStorageUpdated(_ textStorage: NSTextStorage)
    func textStorageDocumentStructure(_ textStorage: NSTextStorage) -> DocumentStructureNode
    func textStorageRulerAnnotations(_ textStorage: NSTextStorage) -> [RulerAnnotation]
    func sourceCodeView(_ sourceCodeView: SourceCodeView, updateCodeHighlightingInRange editedRange: NSRange)
    func sourceCodeView(_ sourceCodeView: SourceCodeView, completionsForLocation location: Int, completionBlock: @escaping (LanguageCompletions?) -> Void)
}

struct RulerAnnotation {
    let lineNumber: Int
    let type: RulerAnnotationType
}

enum RulerAnnotationType {
    case file(relativePath: String)
    case helpFiles([HelpFile])

    var color: NSColor {
        switch self {
        case .file(_):
            return #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        case .helpFiles(_):
            return #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        }
    }
}

struct HelpFile {
    let url: URL
    let description: String?
}

let allLanguageDelegates = [
    "tex": LaTeXLanguageDelegate.self
]
