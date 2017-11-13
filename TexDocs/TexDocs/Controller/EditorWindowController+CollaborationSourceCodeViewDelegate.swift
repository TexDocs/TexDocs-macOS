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
        client.textDidChange(oldRange: oldRange, newRange: newRange, changeInLength: delta, byUser: byUser, to: newString)
    }
    
    func userSelectionDidChange(_ newSelection: NSRange) {
        client.userSelectionDidChange(newSelection)
    }
    
    func collaborationCursors(for editor: CollaborationSourceCodeView) -> [CollaborationCursor] {
        return client.collaborationCursors.map { return $1 }
    }
}
