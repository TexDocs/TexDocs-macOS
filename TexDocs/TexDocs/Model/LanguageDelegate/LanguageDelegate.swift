//
//  LanguageDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 07.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

protocol LanguageDelegate {
    init()
    func prepareForTextStorage(_ textStorage: NSTextStorage)
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
}

let allLanguageDelegates = [
    "tex": LaTeXLanguageDelegate.self
]
