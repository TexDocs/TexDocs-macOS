//
//  DocumentData.swift
//  TexDocs
//
//  Created by Noah Peeters on 13.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

/// Data used for saving and loading a project.
struct DocumentData: Codable {
    
    /// Collaboration data of the project.
    var collaboration: Collaboration?
    
    /// Initializes the document data for a new project.
    ///
    /// - Parameter method: The method used to open the project.
    init(open method: NewProjectOpenMethod) {
        switch method {
        case .create(let serverURL, let repoURL):
            collaboration = Collaboration(
                server: Collaboration.Server(url: serverURL),
                repo: Collaboration.Repo(url: repoURL))
        case .join(let serverURL):
            collaboration = Collaboration(server: Collaboration.Server(url: serverURL))
        case .offline:
            collaboration = nil
        }
    }
    
    /// Data required for collaboration.
    struct Collaboration: Codable {
        /// Collaboration server used for live collaboration.
        var server: Server
        
        /// Repo used for offline collaboration.
        var repo: Repo?
        
        /// Initializes collaboration data with at least a collaboration server.
        ///
        /// - Parameters:
        ///   - server: Collaboration server used for live collaboration.
        ///   - repo: Repo used for offline collaboration.
        init(server: Server, repo: Repo? = nil) {
            self.server = server
            self.repo = repo
        }
        
        struct Server: Codable {
            /// Collaboration web socket server url.
            let url: String
            
            /// Initializes collaboration server data with a url.
            ///
            /// - Parameter url: WebSocketServer url.
            init(url: String) {
                self.url = url
            }
        }
        
        struct Repo: Codable {
            /// Git repo url
            let url: String
            
            /// Initializes repo data with a url.
            ///
            /// - Parameter url: Git url.
            init(url: String) {
                self.url = url
            }
        }
    }
}

extension DocumentData {
    /// Collaboration status of the project
    var isCollaborationEnabled: Bool {
        return collaboration != nil
    }
}
