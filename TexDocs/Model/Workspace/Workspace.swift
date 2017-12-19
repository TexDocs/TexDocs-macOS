//
//  Workspace.swift
//  TexDocs
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class Workspace: NSPersistentDocument {
    var workspaceURL: URL? {
        return fileURL?.deletingLastPathComponent()
    }

    lazy var workspaceModel: WorkspaceModel = managedObjectContext!.fetchOrCreateWorkspaceModel()
    
    override init() {
        super.init()
//        Swift.print(workspaceModel.serverURL)
    }

    init(openMethod: NewProjectOpenMethod) {
        super.init()
        workspaceModel.serverURL = openMethod.serverURL
        workspaceModel.serverProjectID = openMethod.projectID
    }

    var documentData = DocumentData(open: .offline, dataFolderName: "Untitled")
    
    var mainWindowController: EditorWindowController?
    
    override class var autosavesInPlace: Bool {
        return true
    }

    override func write(to absoluteURL: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, originalContentsURL absoluteOriginalContentsURL: URL?) throws {
        try super.write(to: absoluteURL, ofType: typeName, for: saveOperation, originalContentsURL: absoluteURL)
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains the Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("DocumentWindowController")) as! EditorWindowController
        mainWindowController = windowController
        self.addWindowController(windowController)

        Swift.print(workspaceModel.serverURL)
    }

//    override func data(ofType typeName: String) throws -> Data {
//        mainWindowController?.saveAllDocuments()
//        return try JSONEncoder().encode(documentData)
//    }
//
//    override func read(from data: Data, ofType typeName: String) throws {
//        documentData = try JSONDecoder().decode(DocumentData.self, from: data)
//    }

    override func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey : Any]) throws -> NSPrintOperation {
        guard let editor = mainWindowController?.editorWrapperViewController.openedEditorController else {
            throw DocumentError.noEditorOpened
        }

        guard let printOperation = editor.printOperation(withSettings: printSettings) else {
            throw DocumentError.notPrintable
        }

        return printOperation
    }
}

enum DocumentError: Error {
    case noEditorOpened
    case notPrintable
}

extension NSManagedObjectContext {
    func fetchOrCreateWorkspaceModel() -> WorkspaceModel {
        let response = try? fetch(WorkspaceModel.mainFetchRequest())
        return response?.first ?? createWorkspaceModel()
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
        let document = Workspace(openMethod: method)

        document.save(to: projectFileURL, ofType: "SQLite", for: .saveOperation) { error in
            self.addDocument(document)
            document.makeWindowControllers()
            if (displayDocument) {
                document.showWindows()
            }
        }
        
        return document
    }
}
