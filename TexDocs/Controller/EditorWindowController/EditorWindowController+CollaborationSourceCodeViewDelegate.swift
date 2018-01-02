//
//  EditorWindowController+CollaborationSourceCodeViewDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController: CollaborationSourceCodeViewDelegate {
    func collaborationSourceCodeView(_ collaborationSourceCodeView: CollaborationSourceCodeView, textDidChangeInOldRange oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool, to newString: String) {
        if byUser, let fileModel = collaborationSourceCodeView.editableFileSystemItem?.versionedFileModel {
            if oldRange.length > 0 {
                dbUserDeletedText(inFile: fileModel, atLocation: oldRange.location, withLength: oldRange.length)
            }
            if newRange.length > 0 {
                dbUserInsertedText(inFile: fileModel, atLocation: newRange.location, text: newString)
            }
        }
    }

    func collaborationSourceCodeView(_ collaborationSourceCodeView: CollaborationSourceCodeView, userSelectionDidChange newSelection: NSRange) {
    }
    
    func collaborationCursors(for editor: CollaborationSourceCodeView) -> [CollaborationCursor] {
        return []
    }
}
