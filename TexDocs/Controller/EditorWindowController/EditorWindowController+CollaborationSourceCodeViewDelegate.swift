//
//  EditorWindowController+CollaborationSourceCodeViewDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation
import CollaborationKit

extension EditorWindowController: CollaborationSourceCodeViewDelegate {
    func collaborationSourceCodeView(_ collaborationSourceCodeView: CollaborationSourceCodeView, userSelectionDidChange newSelection: NSRange) {
        //TODO implement
    }
    
    func collaborationCursors(for editor: CollaborationSourceCodeView) -> [CollaborationCursor] {
        //TODO implement
        return []
    }
}

extension EditorWindowController: VersionedFileCollaborationDelegate {
    func versionedFile(_ versionedFile: VersionedFileModel, textDidChangeInOldRange oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool, newString: String) {
        if byUser {
            if oldRange.length > 0 {
                dbUserDeletedText(inFile: versionedFile, atLocation: oldRange.location, withLength: oldRange.length)
            }
            if newRange.length > 0 {
                dbUserInsertedText(inFile: versionedFile, atLocation: newRange.location, text: newString)
            }
        }
    }
}
