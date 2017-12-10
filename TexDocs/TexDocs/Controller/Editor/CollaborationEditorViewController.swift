//
//  CollaborationEditorViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class CollaborationEditorViewController: NSViewController, Editor {
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
        editableFileSystemItem.textStorage.delegate = editor
        editor.languageDelegate = editableFileSystemItem.createLanguageDelegate()
        editor.collaborationDelegate = delegateModel?.collaborationDelegate
        editor.sourceCodeViewDelegate = delegateModel?.sourceCodeViewDelegate
    }

    override func viewWillAppear() {
        editor.updateSourceCodeHighlighting(in: editor.stringRange)
    }

    private var delegateModel: CollaborationEditorViewControllerModel?

    static func instantiateController(withFileSystemItem fileSystemItem: EditableFileSystemItem, collaborationDelegate: CollaborationSourceCodeViewDelegate?, sourceCodeViewDelegate: SourceCodeViewDelegate) -> CollaborationEditorViewController {
        let editorController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Editors"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CollaborationEditorViewController")) as! CollaborationEditorViewController
        editorController.editableFileSystemItem = fileSystemItem
        editorController.delegateModel = CollaborationEditorViewControllerModel(collaborationDelegate: collaborationDelegate, sourceCodeViewDelegate: sourceCodeViewDelegate)
        return editorController
    }
}

private struct CollaborationEditorViewControllerModel {
    weak var collaborationDelegate: CollaborationSourceCodeViewDelegate?
    weak var sourceCodeViewDelegate: SourceCodeViewDelegate?
}