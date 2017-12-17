//
//  NewProjectOpenMethod.swift
//  TexDocs
//
//  Created by Noah Peeters on 15.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

enum NewProjectOpenMethod {
    case offline
    case join(serverURL: URL, projectID: String)
    case create(serverURL: URL, repositoryURL: URL)
    
    var serverURL: URL? {
        switch self { case .join(let serverURL, _), .create(let serverURL, _):
            return serverURL
        default:
            return nil
        }
    }
    
    var repositoryURL: URL? {
        switch self {
        case .create(_, let repositoryURL):
            return repositoryURL
        default:
            return nil
        }
    }
}
