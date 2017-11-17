//
//  CollaborationClientError.swift
//  TexDocs
//
//  Created by Noah Peeters on 16.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

enum CollaborationClientError: Error {
    case responseStatusCode(statusCode: Int)
    case receivedInvalidRepoURL(repoURLString: String)
    
    var localizedDescription: String {
        switch self {
        case .responseStatusCode(let statusCode):
            return "Received unexpected status code: \(statusCode)."
        case .receivedInvalidRepoURL(let repoURLString):
            return "Received invalid repo URL: '\(repoURLString)'."
        }
    }
}
