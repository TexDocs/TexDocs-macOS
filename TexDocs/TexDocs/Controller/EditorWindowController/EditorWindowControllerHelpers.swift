//
//  EditorWindowControllerHelpers.swift
//  TexDocs
//
//  Created by Noah Peeters on 17.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController {
    var texDocsDocument: Document? {
        return self.document as? Document
    }
    
    var workspaceURL: URL? {
        return texDocsDocument?.workspaceURL
    }
    
    var localRepositoryURL: URL? {
        guard let workspaceURL = workspaceURL else { return nil }
        return workspaceURL.appendingPathComponent(workspaceURL.lastPathComponent, isDirectory: true)
    }
}
