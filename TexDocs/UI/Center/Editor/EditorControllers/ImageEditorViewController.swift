//
//  ImageEditorViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class ImageEditorViewController: BaseEditorViewController, EditorController {
    @IBOutlet weak var imageView: NSImageView!

    var imageFileSystemItem: ImageFileSystemItem!
    var fileSystemItem: FileSystemItem! {
        return imageFileSystemItem
    }

    let rootDocumentStructureNode: DocumentStructureNode? = nil

    func navigate(to documentStructureNode: DocumentStructureNode) {}

    func collaborationCursorsDidChange() {}

    func receivedChange(in range: NSRange, replaceWith replaceString: String) {}

    func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey: Any]) -> NSPrintOperation? {
        return NSPrintOperation(view: imageView, printInfo: NSPrintInfo(dictionary: printSettings))
    }

    override func willOpen() {
        reloadFromFileSystemItem()
    }

    func reloadFromFileSystemItem() {
        imageView.image = imageFileSystemItem.image.value
    }

    static let displayName: String = NSLocalizedString("TD_IMAGE_EDITOR_NAME", comment: "Name of the image editor")

    static func instantiateController(withFileSystemItem fileSystemItem: FileSystemItem,
                                      windowController: EditorWindowController) -> EditorController? {
        guard let imageFileSystemItem = fileSystemItem as? ImageFileSystemItem else {
            return nil
        }
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Editors"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "ImageEditorViewController")

        let editorController = storyboard.instantiateController(
            withIdentifier: identifier) as? ImageEditorViewController

        editorController?.imageFileSystemItem = imageFileSystemItem
        return editorController
    }
}
