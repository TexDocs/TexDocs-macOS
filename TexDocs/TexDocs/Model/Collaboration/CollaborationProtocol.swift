//
//  CollaborationProtocol.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

enum PackgeID: String, Codable {
    case join = "project-open"
}

struct BasePackage: Codable {
    let packageID: PackgeID?
    let statusCode: Int
    
    enum CodingKeys: String, CodingKey {
        case packageID = "type"
        case statusCode = "status"
    }
}


struct ProjectJoinPackage: Codable {
    let userID: String
    let repoURL: String
}
