//
//  FileManager+Helpers.swift
//  TexDocs
//
//  Created by Noah Peeters on 06.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension FileManager {
    func renameItem(at url: URL, to newName: String) throws {
        try moveItem(at: url, to: url.deletingLastPathComponent().appendingPathComponent(newName))
    }
}
