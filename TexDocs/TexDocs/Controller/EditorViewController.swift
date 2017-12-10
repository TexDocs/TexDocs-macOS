//
//  EditorViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

protocol Editor: class {
    var fileSystemItem: FileSystemItem! { get }
    var rootDocumentStructureNode: DocumentStructureNode? { get }

    func navigate(to documentStructureNode: DocumentStructureNode)
    func collaborationCursorsDidChange()

    func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey : Any]) -> NSPrintOperation?

    // MARK: NSViewController functions
    func removeFromSuperview()
    var view: NSView { get }
}

class EditorViewController: NSViewController {
    @IBOutlet private weak var backButton: NSButton!
    @IBOutlet private weak var nextButton: NSButton!
    @IBOutlet weak var editorContainerView: NSView!

    
    private var fileHistory: [Editor] = []
    private var openedFileIndex: Int = -1
    private(set) var openedEditor: Editor?

    var openedFile: FileSystemItem? {
        return openedEditor?.fileSystemItem
    }

    func navigate(to documentStructureNode: DocumentStructureNode) {
        fileHistory[openedFileIndex].navigate(to: documentStructureNode)
    }

    override func viewDidLoad() {
        updateNavigationButtons()
    }

    func pushToOpenedFiles(_ editor: Editor) {
        fileHistory.removeLast(fileHistory.count - openedFileIndex - 1)
        fileHistory.append(editor)
        openedFileIndex += 1
        openEditorAtFileIndex()
        updateNavigationButtons()
    }

    func srcDirectoryDidChange() {
        var currentIndex = 0

        while currentIndex < fileHistory.count {
            if fileHistory[currentIndex].fileSystemItem.isDeleted {
                let editorContainerViewController = fileHistory.remove(at: currentIndex)

                if currentIndex < openedFileIndex {
                    openedFileIndex -= 1
                } else if currentIndex == openedFileIndex {
                    editorContainerViewController.view.removeFromSuperview()
                }
            } else {
                currentIndex += 1
            }
        }

        openedFileIndex = min(openedFileIndex, fileHistory.count - 1)
        updateNavigationButtons()
        openEditorAtFileIndex()
    }

    private func openEditorAtFileIndex() {
        open(editor: fileHistory[openedFileIndex])
    }

    private func open(editor: Editor) {
        openedEditor?.view.removeFromSuperview()
        editorContainerView.addSubview(editor.view)
        openedEditor = editor

        editor.view.translatesAutoresizingMaskIntoConstraints = false
        editor.view.leftAnchor.constraint(equalTo: editorContainerView.leftAnchor).isActive = true
        editor.view.rightAnchor.constraint(equalTo: editorContainerView.rightAnchor).isActive = true
        editor.view.topAnchor.constraint(equalTo: editorContainerView.topAnchor).isActive = true
        editor.view.bottomAnchor.constraint(equalTo: editorContainerView.bottomAnchor).isActive = true
    }

    private func updateNavigationButtons() {
        backButton.isEnabled = openedFileIndex > 0
        nextButton.isEnabled = openedFileIndex < fileHistory.count - 1
    }

    @IBAction func goToPreviousFile(_ sender: Any) {
        openedFileIndex -= 1
        openEditorAtFileIndex()
        updateNavigationButtons()
    }

    @IBAction func goToNextFile(_ sender: Any) {
        openedFileIndex += 1
        openEditorAtFileIndex()
        updateNavigationButtons()
    }
}

extension FileSystemItem {
    fileprivate var isDeleted: Bool {
        return !FileManager.default.fileExists(atPath: url.path)
    }
}
