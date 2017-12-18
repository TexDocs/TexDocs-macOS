//
//  EditorViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class EditorWrapperViewController: NSViewController {
    @IBOutlet private weak var backButton: NSButton!
    @IBOutlet private weak var nextButton: NSButton!
    @IBOutlet weak var editorContainerView: NSView!
    @IBOutlet weak var pathLabel: NSTextField!

    private var editorControllerHistory: [EditorController] = []
    private var openedEditorControllerIndex: Int = -1
    private(set) var openedEditorController: EditorController?

    weak var delegate: EditorWrapperViewControllerDelegate?

    var openedFile: FileSystemItem? {
        return openedEditorController?.fileSystemItem
    }

    func navigate(to documentStructureNode: DocumentStructureNode) {
        editorControllerHistory[openedEditorControllerIndex].navigate(to: documentStructureNode)
    }

    override func viewDidLoad() {
        updateNavigationButtons()
    }

    func pushToOpenedFiles(_ editorController: EditorController) {
        editorControllerHistory.removeLast(editorControllerHistory.count - openedEditorControllerIndex - 1)
        editorControllerHistory.append(editorController)
        openedEditorControllerIndex += 1
        openEditorControllerAtCurrentIndex()
        updateNavigationButtons()
    }

    func srcDirectoryDidChange() {
        var currentIndex = 0

        while currentIndex < editorControllerHistory.count {
            if editorControllerHistory[currentIndex].fileSystemItem.isDeleted {
                let editorContainerViewController = editorControllerHistory.remove(at: currentIndex)

                if currentIndex < openedEditorControllerIndex {
                    openedEditorControllerIndex -= 1
                } else if currentIndex == openedEditorControllerIndex {
                    editorContainerViewController.view.removeFromSuperview()
                }
            } else {
                currentIndex += 1
            }
        }

        openedEditorControllerIndex = min(openedEditorControllerIndex, editorControllerHistory.count - 1)
        updateNavigationButtons()
        openEditorControllerAtCurrentIndex()
    }

    private func openEditorControllerAtCurrentIndex() {
        guard openedEditorControllerIndex >= 0 else {
            return
        }
        open(editor: editorControllerHistory[openedEditorControllerIndex])
    }

    private func open(editor: EditorController) {
        guard openedEditorController !== editor else {
            return
        }

        openedEditorController?.view.removeFromSuperview()
        editorContainerView.addSubview(editor.view)
        openedEditorController = editor
        pathLabel.stringValue = editor.fileSystemItem.url.path

        editor.view.translatesAutoresizingMaskIntoConstraints = false
        editor.view.leftAnchor.constraint(equalTo: editorContainerView.leftAnchor).isActive = true
        editor.view.rightAnchor.constraint(equalTo: editorContainerView.rightAnchor).isActive = true
        editor.view.topAnchor.constraint(equalTo: editorContainerView.topAnchor).isActive = true
        editor.view.bottomAnchor.constraint(equalTo: editorContainerView.bottomAnchor).isActive = true

        delegate?.editorWrapperViewController(self, opened: editor)
    }

    private func updateNavigationButtons() {
        backButton.isEnabled = openedEditorControllerIndex > 0
        nextButton.isEnabled = openedEditorControllerIndex < editorControllerHistory.count - 1
    }

    @IBAction func goToPreviousFile(_ sender: Any) {
        openedEditorControllerIndex -= 1
        openEditorControllerAtCurrentIndex()
        updateNavigationButtons()
    }

    @IBAction func goToNextFile(_ sender: Any) {
        openedEditorControllerIndex += 1
        openEditorControllerAtCurrentIndex()
        updateNavigationButtons()
    }
}

protocol EditorWrapperViewControllerDelegate: class {
    func editorWrapperViewController(_ editorWrapperViewController: EditorWrapperViewController, opened editor: EditorController)
}

extension FileSystemItem {
    fileprivate var isDeleted: Bool {
        return !FileManager.default.fileExists(atPath: url.path)
    }
}
