//
//  EditorViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class EditorViewController: NSViewController {
    @IBOutlet private var editorView: CollaborationSourceCodeView!
    @IBOutlet private weak var emptyStateImage: NSImageView!
    @IBOutlet private weak var emptyStateOpenInButton: NSButton!
    @IBOutlet private weak var backButton: NSButton!
    @IBOutlet private weak var nextButton: NSButton!
    
    private var fileHistory: [FileSystemItem] = []
    private var openedFileIndex: Int = -1
    private var openedFile: FileSystemItem? {
        guard openedFileIndex > -1 else { return nil }
        return fileHistory[openedFileIndex]
    }

    override func viewDidLoad() {
        editorView.backgroundColor = ThemesHandler.default.color(for: .editorBackground)
        updateNavigationButtons()
    }

    func pushToOpenedFiles(_ item: FileSystemItem) {
        fileHistory.removeLast(fileHistory.count - openedFileIndex - 1)
        fileHistory.append(item)
        openedFileIndex += 1
        openFileAtFileIndex()
        updateNavigationButtons()
    }

    func srcDirectoryDidChange() {
        var currentIndex = 0

        while currentIndex < fileHistory.count {
            if fileHistory[currentIndex].isDeleted {
                fileHistory.remove(at: currentIndex)
                if currentIndex < openedFileIndex {
                    openedFileIndex -= 1
                }
            } else {
                currentIndex += 1
            }
        }

        openedFileIndex = min(openedFileIndex, fileHistory.count - 1)
        updateNavigationButtons()
        openFileAtFileIndex()
    }

    private func openFileAtFileIndex() {
        open(item: openedFile)
    }

    private func open(item: FileSystemItem?) {
        if let editableFileSystemItem = item as? EditableFileSystemItem {
            editorView.openFile(editableFileSystemItem)
            updateEmptyState(withItem: nil)
        } else {
            editorView.openFile(nil)
            updateEmptyState(withItem: item)
        }
    }

    private func updateEmptyState(withItem item: FileSystemItem?) {
        guard let item = item else {
            emptyStateImage.isHidden = true
            emptyStateOpenInButton.isHidden = true
            return
        }

        emptyStateImage.isHidden = false
        emptyStateImage.image = NSWorkspace.shared.icon(forFile: item.url.path)

        guard let defaultApplicationName = NSWorkspace.shared.urlForApplication(toOpen: item.url)?.lastPathComponent else {
            emptyStateOpenInButton.isHidden = true
            return
        }

        emptyStateOpenInButton.isHidden = false
        emptyStateOpenInButton.title = "Open in \(defaultApplicationName)"
        emptyStateOpenInButton.sizeToFit()
    }

    private func updateNavigationButtons() {
        backButton.isEnabled = openedFileIndex > 0
        nextButton.isEnabled = openedFileIndex < fileHistory.count - 1
    }

    @IBAction func openInDefaultApplication(_ sender: Any) {
        NSWorkspace.shared.open(openedFile!.url)
    }

    @IBAction func goToPreviousFile(_ sender: Any) {
        openedFileIndex -= 1
        openFileAtFileIndex()
        updateNavigationButtons()
    }

    @IBAction func goToNextFile(_ sender: Any) {
        openedFileIndex += 1
        openFileAtFileIndex()
        updateNavigationButtons()
    }
}


extension FileSystemItem {
    fileprivate var isDeleted: Bool {
        return !FileManager.default.fileExists(atPath: url.path)
    }
}
