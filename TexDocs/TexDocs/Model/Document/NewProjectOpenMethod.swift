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
    case join(serverURL: URL)
    case create(serverURL: URL, repoURL: URL)
    
    var serverURL: URL? {
        switch self { case .join(let serverURL), .create(let serverURL, _):
            return serverURL
        default:
            return nil
        }
    }
    
    var repoURL: URL? {
        switch self {
        case .create(_, let repoURL):
            return repoURL
        default:
            return nil
        }
    }
}
