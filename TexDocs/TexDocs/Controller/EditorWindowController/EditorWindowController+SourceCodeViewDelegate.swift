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
}