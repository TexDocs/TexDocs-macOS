//
//  EditorWindowController+SourceCodeViewDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 09.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController: SourceCodeViewDelegate {
    func sourceCodeViewStructureChanged(_ sourceCodeView: SourceCodeView) {
        outlineViewController.reloadData(inTab: .structure)
    }

    func sourceCodeView(_ sourceCodeView: SourceCodeView, annotationClicked annotation: RulerAnnotation) {
        switch annotation.type {
        case .file(let relativePath):
            if let fileSystemItem = rootDirectory?.findChild(withRelativePath: relativePath) {
                open(fileSystemItem: fileSystemItem, withEditorControllerType: nil)
            }
        }
    }
}

extension EditorWindowController: EditorWrapperViewControllerDelegate {
    func editorWrapperViewController(_ editorWrapperViewController: EditorWrapperViewController, opened editor: EditorController) {
        outlineViewController.reloadData(inTab: .structure)
    }
}
