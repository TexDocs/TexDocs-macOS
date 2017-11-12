//
//  Document.swift
//  TexDocs
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    override init() {
        super.init()
    }

    init(localURL: URL) {
        documentData = DocumentData(localURL: localURL)
    }
    
    var documentData: DocumentData?
    
    override class var autosavesInPlace: Bool {
        return true
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
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

struct DocumentData: Codable {
    let localURL: URL
}

class TexDocsDocumentController: NSDocumentController {
    override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("NewProjectWindowController")) as! NSWindowController
        
        guard NSApplication.shared.runModal(for: windowController.window!) == .OK,
            let method = (windowController.contentViewController as? NewProjectViewController)?.method else {
            return NSDocument()
        }
        
        try! FileManager.default.createDirectory(at: method.localURL, withIntermediateDirectories: true, attributes: nil)
        
        let projectFileURL = method.localURL.appendingPathComponent(method.localURL.lastPathComponent).appendingPathExtension("texdocs")
        let document = Document(localURL: method.localURL)
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
