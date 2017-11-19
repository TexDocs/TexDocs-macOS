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
    
    /// Name of the repository folder.
    var dataFolderName: String
    
    /// Initializes the document data for a new project.
    ///
    /// - Parameter method: The method used to open the project.
    init(open method: NewProjectOpenMethod, dataFolderName: String) {
        switch method {
        case .create(let serverURL, let repositoryURL):
            collaboration = Collaboration(
                server: Collaboration.Server(url: serverURL),
                repository: Collaboration.Repository(url: repositoryURL))
        case .join(let serverURL):
            collaboration = Collaboration(server: Collaboration.Server(url: serverURL))
        case .offline:
            collaboration = nil
        }
        self.dataFolderName = dataFolderName
    }
    
    /// Data required for collaboration.
    struct Collaboration: Codable {
        /// Collaboration server used for live collaboration.
        var server: Server
        
        /// Repository used for offline collaboration.
        var repository: Repository?
        
        /// Initializes collaboration data with at least a collaboration server.
        ///
        /// - Parameters:
        ///   - server: Collaboration server used for live collaboration.
        ///   - repository: Repository used for offline collaboration.
        init(server: Server, repository: Repository? = nil) {
            self.server = server
            self.repository = repository
        }
        
        struct Server: Codable {
            /// Collaboration web socket server url.
            let url: URL
            
            /// Initializes collaboration server data with a url.
            ///
            /// - Parameter url: WebSocketServer url.
            init(url: URL) {
                self.url = url
            }
        }
        
        struct Repository: Codable {
            /// Git repository url
            let url: URL
            
            /// Initializes repository data with a url.
            ///
            /// - Parameter url: Git url.
            init(url: URL) {
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
