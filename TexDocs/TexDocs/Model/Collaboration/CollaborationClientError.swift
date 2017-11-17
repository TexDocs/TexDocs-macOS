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
    case receivedInvalidRepositoryURL(repositoryURLString: String)
    
    var localizedDescription: String {
        switch self {
        case .responseStatusCode(let statusCode):
            return "Received unexpected status code: \(statusCode)."
        case .receivedInvalidRepositoryURL(let repositoryURLString):
            return "Received invalid repository URL: '\(repositoryURLString)'."
        }
    }
}
