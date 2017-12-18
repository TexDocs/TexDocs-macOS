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
            return "\(NSLocalizedString("TD_ERROR_UNEXPECTED_STATUS_CODE", comment: "Error message if a received message is corrupted.")): \(statusCode)."
        case .receivedInvalidRepositoryURL(let repositoryURLString):
            return "\(NSLocalizedString("TD_INVALID_REPOSITORY_URL", comment: "Error message if the received repository url is invalid.")): '\(repositoryURLString)'."
        }
    }
}
