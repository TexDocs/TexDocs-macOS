//
//  DocumentData.swift
//  TexDocs
//
//  Created by Noah Peeters on 13.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

struct DocumentData: Codable {
    let repoURL: String?
    let server: Server?
    
    init(open method: NewProjectOpenMethod) {
        repoURL = method.repoURL
        
        if let serverURL = method.serverURL {
            server = Server(url: serverURL)
        } else {
            server = nil
        }
    }
    
    struct Server: Codable {
        let url: String
    }
}

extension DocumentData {
    var isOnline: Bool {
        return server != nil
    }
}
