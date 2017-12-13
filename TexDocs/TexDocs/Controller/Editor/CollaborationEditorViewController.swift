//
//  CollaborationEditorViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class CollaborationEditorViewController: BaseEditorViewController, EditorController, SourceCodeViewInteractionDelegate {

    @IBOutlet weak var editor: CollaborationSourceCodeView!

    var fileSystemItem: FileSystemItem! {
        return editableFileSystemItem
    }

    var editableFileSystemItem: EditableFileSystemItem!
    
    var rootDocumentStructureNode: DocumentStructureNode? {
        return editor.rootStructureNode?.value
    }

    func navigate(to documentStructureNode: DocumentStructureNode) {
        editor.setSelectedRange(documentStructureNode.definitionRange)
        editor.scrollRangeToVisible(documentStructureNode.effectiveRange)
        editor.window?.makeFirstResponder(editor)
    }

    func collaborationCursorsDidChange() {
        editor.collaborationCursorsDidChange()
    }

    func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey : Any]) -> NSPrintOperation? {
        var settings = printSettings
        settings[NSPrintInfo.AttributeKey.verticallyCentered] = NSNumber(value: false)

        return NSPrintOperation(view: editor, printInfo: NSPrintInfo(dictionary: settings))
    }

    override func viewDidLoad() {
        editor.layoutManager?.replaceTextStorage(editableFileSystemItem.textStorage)
        editableFileSystemItem.delegates.add(delegate: editor)

        editor.languageDelegate = editableFileSystemItem.languageDelegate
        editor.collaborationDelegate = delegateModel?.collaborationDelegate
        editor.sourceCodeViewDelegate = delegateModel?.sourceCodeViewDelegate
        editor.interactionDelegate = self
    }

    override func willOpen() {
        editableFileSystemItem.deselectAllTokens()
        editor.updateSourceCodeHighlighting(in: editor.stringRange)
    }

    func sourceCodeViewDeselectTokens(_ sourceCodeView: SourceCodeView) {
        editableFileSystemItem.deselectAllTokens()
    }

    private var delegateModel: CollaborationEditorViewControllerModel?

    static let displayName: String = NSLocalizedString("TD_COLLABORATION_EDITOR_NAME", comment: "The display name of the collaboration editor")

    static func instantiateController(withFileSystemItem fileSystemItem: FileSystemItem, windowController: EditorWindowController) -> EditorController? {
        guard let editableFileSystemItem = fileSystemItem as? EditableFileSystemItem else {
            return nil
        }
        let editorController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Editors"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CollaborationEditorViewController")) as! CollaborationEditorViewController
        editorController.editableFileSystemItem = editableFileSystemItem
        editorController.delegateModel = CollaborationEditorViewControllerModel(collaborationDelegate: windowController, sourceCodeViewDelegate: windowController)
        return editorController
    }
}

private struct CollaborationEditorViewControllerModel {
    weak var collaborationDelegate: CollaborationSourceCodeViewDelegate?
    weak var sourceCodeViewDelegate: SourceCodeViewDelegate?
}
