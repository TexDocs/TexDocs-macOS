//
//  BaseCommit.swift
//  TexDocs
//
//  Created by Noah Peeters on 20.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//


import Foundation

protocol FileContentCommit {
    var relativePath: String? { get }
}

extension FileContentCommitModel: FileContentCommit {
    var relativePath: String? {
        return file?.relativePath
    }
}
