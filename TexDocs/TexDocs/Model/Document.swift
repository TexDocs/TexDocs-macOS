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
        // Add your subclass-specific initialization here.
    }

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
        
        
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
}

struct DocumentData: Codable {
    let url: URL
}

class TexDocsDocumentController: NSDocumentController {
    override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("NewProjectWindowController")) as! NSWindowController
        
        
        NSApp.runModal(for: windowController.window!)
        
        return NSDocument()
//        windowController.runM
        
//        self.window?.beginSheet(windowController.window!, completionHandler: nil)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.window?.endSheet(windowController.window!)
//        }
        
//        let doc: NSDocument
//        let savePanel = NSSavePanel()
//
//        savePanel.prompt = "Create"
//
//        let modelResponse = savePanel.runModal()
//
//        print(modelResponse)
//
//        if modelResponse == .OK {
//            print("ok")
//        }
//
//
//
//        print("untitled")
//        return try super.openUntitledDocumentAndDisplay(displayDocument)
    }
    
//    override func makeUntitledDocument(ofType typeName: String) throws -> NSDocument {
//
//
//
//        print(typeName)
//        return try super.makeUntitledDocument(ofType: typeName)
//    }
}
