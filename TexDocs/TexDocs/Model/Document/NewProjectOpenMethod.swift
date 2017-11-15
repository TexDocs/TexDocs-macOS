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
    case join(serverURL: String)
    case create(serverURL: String, repoURL: String)
    
    var serverURL: String? {
        switch self { case .join(let serverURL), .create(let serverURL, _):
            return serverURL
        default:
            return nil
        }
    }
    
    var repoURL: String? {
        switch self {
        case .create(_, let repoURL):
            return repoURL
        default:
            return nil
        }
    }
}
