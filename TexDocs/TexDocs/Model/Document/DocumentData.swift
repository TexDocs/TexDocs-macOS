//
//  DocumentData.swift
//  TexDocs
//
//  Created by Noah Peeters on 13.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

struct DocumentData: Codable {
    var repo: Repo? = nil
    var server: Server? = nil
    
    init(open method: NewProjectOpenMethod) {
        if let repoURL = method.repoURL {
            repo = Repo(url: repoURL)
        }
        
        if let serverURL = method.serverURL {
            server = Server(url: serverURL)
        }
    }
    
    struct Server: Codable {
        let url: String
    }
    
    struct Repo: Codable {
        let url: String
    }
}

extension DocumentData {
    var isOnline: Bool {
        return server != nil
    }
}
