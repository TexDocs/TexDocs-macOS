//
//  FileTypeHandler.swift
//  TexDocs
//
//  Created by Noah Peeters on 19.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

struct FileTypeHandler {
    private static var ignoredFileNames: Set =  [
        ".DS_Store"
    ]
    
    private static var modificationsIgnored: Set = [
        "tex"
    ]
    
    private static var supportEditing: Set = [
        "tex"
    ]
    
    private init() {}
    
    static func shouldIgnoreEvent(of path: URL) -> Bool {
        return ignoredFileNames.contains(path.lastPathComponent)
    }
    
    static func shouldIgnoreModification(of path: URL) -> Bool {
        return modificationsIgnored.contains(path.pathExtension)
    }
    
    static func supportEditing(of path: URL) -> Bool {
        return supportEditing.contains(path.pathExtension)
    }
}
