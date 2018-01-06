//
//  TexDocsDocumentController.swift
//  TexDocs
//
//  Created by Noah Peeters on 20.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class TexDocsDocumentController: NSDocumentController {
    override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {

        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        // swiftlint:disable force_cast
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("NewProjectWindowController")) as! NSWindowController

        guard NSApplication.shared.runModal(for: windowController.window!) == .OK,
            let controller = windowController.contentViewController as? NewProjectViewController,
            let method = controller.method,
            let localURL = controller.localURL else {
                return NSDocument()
        }

        // swiftlint:disable force_try
        try! FileManager.default.createDirectory(at: localURL, withIntermediateDirectories: true, attributes: nil)

        let projectFileURL = localURL.appendingPathComponent(localURL.lastPathComponent).appendingPathExtension("texdocs")
        let document = Workspace(openMethod: method)

        document.save(to: projectFileURL, ofType: "SQLite", for: .saveOperation) { _ in
            self.addDocument(document)
            document.makeWindowControllers()
            if displayDocument {
                document.showWindows()
            }
        }

        return document
    }
}
