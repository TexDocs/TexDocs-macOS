//
//  Document.swift
//  TexDocs
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    var workspaceURL: URL? {
        return fileURL?.deletingLastPathComponent()
    }
    
    override init() {
        super.init()
    }

    init(documentData: DocumentData) {
        self.documentData = documentData
        super.init()
    }
    
    var documentData: DocumentData?
    
    override class var autosavesInPlace: Bool {
        return true
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains the Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! EditorWindowController
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        return try JSONEncoder().encode(documentData)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        documentData = try JSONDecoder().decode(DocumentData.self, from: data)
    }
}

class TexDocsDocumentController: NSDocumentController {
    override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("NewProjectWindowController")) as! NSWindowController
        
        guard NSApplication.shared.runModal(for: windowController.window!) == .OK,
            let controller = windowController.contentViewController as? NewProjectViewController,
            let method = controller.method,
            let localURL = controller.localURL else {
            return NSDocument()
        }
        
        try! FileManager.default.createDirectory(at: localURL, withIntermediateDirectories: true, attributes: nil)
        
        let projectFileURL = localURL.appendingPathComponent(localURL.lastPathComponent).appendingPathExtension("texdocs")
        let document = Document(documentData: DocumentData(open: method))
        document.save(to: projectFileURL, ofType: "", for: .saveOperation) { error in
            self.addDocument(document)
            document.makeWindowControllers()
            if (displayDocument) {
                document.showWindows()
            }
        }
        
        return document
    }
}
