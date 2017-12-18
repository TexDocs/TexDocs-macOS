//
//  EditorWindowController+SourceCodeViewDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 09.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

extension EditorWindowController: SourceCodeViewDelegate {
    func sourceCodeViewStructureChanged(_ sourceCodeView: SourceCodeView) {
        outlineViewController.reloadData(inTab: .structure)
    }

    func sourceCodeView(_ sourceCodeView: SourceCodeView, annotationClicked annotation: RulerAnnotation, inRuler ruler: NSRulerView, rect: NSRect) {
        switch annotation.type {
        case .file(let relativePath):
            if let fileSystemItem = rootDirectory?.findChild(withRelativePath: relativePath) {
                open(fileSystemItem: fileSystemItem, withEditorControllerType: nil)
            }
        case .helpFiles(let helpFiles):
            if let helpFile = helpFiles.first(where: {
                $0.url.pathExtension == "pdf"
            }) {
                pdfViewController.showPDF(withURL: helpFile.url)
            }
        }
    }
}

extension EditorWindowController: EditorWrapperViewControllerDelegate {
    func editorWrapperViewController(_ editorWrapperViewController: EditorWrapperViewController, opened editor: EditorController) {
        outlineViewController.reloadData(inTab: .structure)
    }
}
