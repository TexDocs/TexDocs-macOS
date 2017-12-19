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

    var schemes: [Scheme]

    func scheme(withUUID uuid: UUID) -> Scheme? {
        return schemes.first { $0.uuid == uuid }
    }
    
    /// Initializes the document data for a new project.
    ///
    /// - Parameter method: The method used to open the project.
    init(open method: NewProjectOpenMethod, dataFolderName: String) {
        switch method {
        case .create(let serverURL):
            collaboration = Collaboration(baseURL: serverURL, projectID: nil)
        case .join(let serverURL, let projectID):
            collaboration = Collaboration(baseURL: serverURL, projectID: projectID)
        case .offline:
            collaboration = nil
        }
        self.dataFolderName = dataFolderName
        self.schemes = []
    }
    
    /// Data required for collaboration.
    struct Collaboration: Codable {
        /// Collaboration server used for live collaboration.
        let baseURL: URL
        var projectID: String?

        var joinURL: URL? {
            guard let projectID = projectID else {
                return nil
            }
            return baseURL.appendingPathComponent("project/join/\(projectID)")
        }

        var shareURL: URL? {
            guard let projectID = projectID else {
                return nil
            }
            return baseURL.appendingPathComponent("?\(projectID)")
        }

        var createURL: URL? {
            return baseURL.appendingPathComponent("project/create/")
        }
        
        /// Initializes collaboration data with at least a collaboration server.
        ///
        /// - Parameters:
        ///   - server: Collaboration server used for live collaboration.
        ///   - repository: Repository used for offline collaboration.
        init(baseURL: URL, projectID: String?) {
            self.baseURL = baseURL
            self.projectID = projectID
        }
    }

    class Scheme: Codable {
        let uuid: UUID
        var name: String
        var path: String

        init(name: String, path: String) {
            self.uuid = UUID()
            self.name = name
            self.path = path
        }
    }
}

extension DocumentData {
    /// Collaboration status of the project
    var isCollaborationEnabled: Bool {
        return collaboration != nil
    }
}
