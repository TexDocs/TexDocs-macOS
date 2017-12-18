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
    case create(serverURL: URL)
    case join(serverURL: URL, projectID: String)
    
    var serverURL: URL? {
        switch self { case .join(let serverURL, _), .create(let serverURL):
            return serverURL
        default:
            return nil
        }
    }
}
