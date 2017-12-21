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
    let databaseQueue = DispatchQueue(label: "Workspace Queue")
    
    override init() {
        super.init()
    }

    init(openMethod: NewProjectOpenMethod) {
        super.init()
        workspaceModel.serverURL = openMethod.serverURL
        workspaceModel.serverProjectID = openMethod.projectID
    }
    
    var mainWindowController: EditorWindowController?
    
    override class var autosavesInPlace: Bool {
        return true
    }

    override func write(to absoluteURL: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, originalContentsURL absoluteOriginalContentsURL: URL?) throws {
        try super.write(to: absoluteURL, ofType: typeName, for: saveOperation, originalContentsURL: absoluteURL)
        // TODO: Write documents to file system
    }
    
    override func makeWindowControllers() {

        // TODO: Stuff
        asyncDatabaseOperations(operations: {
            let date = Date().timeIntervalSince1970
            Swift.print(date)
//            self.workspaceModel.addToSchemes($0.createSchemeModel(name: "Test Scheme \(date)", path: "this/is/a/path/to/a/file.tex"))

//            try? self.workspaceModel.currentFilesFetchedResultController.performFetch()
            let currentFiles = self.workspaceModel.currentFilesFetchedResultController.fetch()

            Swift.print(currentFiles)
            for file in currentFiles {
//                try? self.workspaceModel.currentFilesFetchedResultController.performFetch()

                self.workspaceModel.appendCommit($0.createDeleteFileCommit(forFile: file))
            }
//            try? self.workspaceModel.currentFilesFetchedResultController.performFetch()
            Swift.print(self.workspaceModel.currentFilesFetchedResultController.fetch())

            let file = $0.createBinaryFile(atPath: "a/path/to/a/file", withContent: "\(date)".data(using: .utf8)!)
            self.workspaceModel.addToFiles(file)
            self.workspaceModel.appendCommit(file.createCommit!)

//            try? self.workspaceModel.currentFilesFetchedResultController.performFetch()
            Swift.print(self.workspaceModel.currentFilesFetchedResultController.fetch())
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            Swift.print(String(data: ((self.workspaceModel.commitsFetchedResultController[0] as? CreateFileCommit)?.createdFile?.data?.data)!, encoding: .utf8))
        }

        // Returns the Storyboard that contains the Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("DocumentWindowController")) as! EditorWindowController
        mainWindowController = windowController
        self.addWindowController(windowController)
    }

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
