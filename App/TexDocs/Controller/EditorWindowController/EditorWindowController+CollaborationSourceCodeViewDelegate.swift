//
//  EditorWindowController+CollaborationSourceCodeViewDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController: CollaborationSourceCodeViewDelegate {
    func textDidChange(oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool, to newString: String) {
        client.textDidChange(oldRange: oldRange, newRange: newRange, changeInLength: delta, byUser: byUser, to: newString, inFile: relativePathOfOpenedFileInDataFolder()!)
        editedDocument()
        if byUser {
            resetAutoTypesetTimer()
        }
    }
    
    func userSelectionDidChange(_ newSelection: NSRange) {
        guard let relativeFilePath = relativePathOfOpenedFileInDataFolder() else { return }
        client.userSelectionDidChange(newSelection, inFile: relativeFilePath)
    }
    
    func collaborationCursors(for editor: CollaborationSourceCodeView) -> [CollaborationCursor] {
        let relativeFilePath = relativePathOfOpenedFileInDataFolder()
        return client.collaborationCursors
            .map { return $1 }
            .filter { $0.relativeFilePath == relativeFilePath }
    }
}
