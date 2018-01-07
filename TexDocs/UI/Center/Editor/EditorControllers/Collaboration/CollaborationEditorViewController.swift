//
//  CollaborationEditorViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class CollaborationEditorViewController: BaseEditorViewController, EditorController {

    @IBOutlet weak var editor: CollaborationSourceCodeView!

    var fileSystemItem: FileSystemItem! {
        return editableFileSystemItem
    }

    var editableFileSystemItem: EditableFileSystemItem!

    var rootDocumentStructureNode: DocumentStructureNode? {
        return editableFileSystemItem.rootStructureNode
    }

    func navigate(to documentStructureNode: DocumentStructureNode) {
        editor.setSelectedRange(documentStructureNode.definitionRange)
        editor.scrollRangeToVisible(documentStructureNode.effectiveRange)
        editor.window?.makeFirstResponder(editor)
    }

    func collaborationCursorsDidChange() {
        editor.collaborationCursorsDidChange()
    }

    func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey: Any]) -> NSPrintOperation? {
        var settings = printSettings
        settings[NSPrintInfo.AttributeKey.verticallyCentered] = NSNumber(value: false)

        return NSPrintOperation(view: editor, printInfo: NSPrintInfo(dictionary: settings))
    }

    override func viewDidLoad() {
        editor.layoutManager?.replaceTextStorage(editableFileSystemItem.textStorage)
        editableFileSystemItem.versionedFileModel.delegates.add(delegate: editor)

        editor.editableFileSystemItem = editableFileSystemItem
        editor.collaborationDelegate = delegateModel?.collaborationDelegate
        editor.sourceCodeViewDelegate = delegateModel?.sourceCodeViewDelegate
        editor.backgroundColor = ThemesHandler.default.color(for: .editorBackground)
    }

    override func willOpen() {
//        editableFileSystemItem.textStorage.deselectAllTokens()
        editor.updateSourceCodeHighlighting(in: editor.stringRange)
    }

    private var delegateModel: CollaborationEditorViewControllerModel?

    static let displayName: String = NSLocalizedString("TD_COLLABORATION_EDITOR_NAME", comment: "The display name of the collaboration editor")

    static func instantiateController(withFileSystemItem fileSystemItem: FileSystemItem, windowController: EditorWindowController) -> EditorController? {
        guard let editableFileSystemItem = fileSystemItem as? EditableFileSystemItem else {
            return nil
        }
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Editors"), bundle: nil)
        let editorController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CollaborationEditorViewController")) as? CollaborationEditorViewController
        editorController?.editableFileSystemItem = editableFileSystemItem
        editorController?.delegateModel = CollaborationEditorViewControllerModel(collaborationDelegate: windowController, sourceCodeViewDelegate: windowController)
        return editorController
    }
}

private struct CollaborationEditorViewControllerModel {
    weak var collaborationDelegate: CollaborationSourceCodeViewDelegate?
    weak var sourceCodeViewDelegate: SourceCodeViewDelegate?
}
