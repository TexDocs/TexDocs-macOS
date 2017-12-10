//
//  SourceCodeViewLanguageDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 07.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

protocol SourceCodeViewLanguageDelegate {
    init()
    func sourceCodeView(_ sourceCodeView: SourceCodeView, updateCodeHighlightingInRange editedRange: NSRange)
    func sourceCodeViewDocumentStructure(_ sourceCodeView: SourceCodeView) -> DocumentStructureNode
    func sourceCodeView(_ sourceCodeView: SourceCodeView, completionsForLocation location: Int, completionBlock: @escaping (LanguageCompletions?) -> Void)
}

let allLanguageDelegates = [
    "tex": LaTeXSourceCodeViewLanguageDelegate.self
]


