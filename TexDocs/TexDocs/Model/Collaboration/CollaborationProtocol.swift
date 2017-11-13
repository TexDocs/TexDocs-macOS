//
//  CollaborationProtocol.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

enum ReceivedPackgeID: String, Codable {
    case join = "project-open"
    case collaboratorCurserUpdate = "cursor"
}

enum SendPackageID: String, Codable {
    case userCurserUpdate = "cursor"
}

struct BasePackage: Codable {
    let packageID: ReceivedPackgeID?
    let statusCode: Int
    
    enum CodingKeys: String, CodingKey {
        case packageID = "type"
        case statusCode = "status"
    }
}

// MARK: Server -> Client

struct ProjectJoinPackage: Codable {
    let userID: String
    let repoURL: String
}

struct CollaborationCursorUpdatePackage: Codable {
    let userID: String
    let start: Int
    let length: Int
    
    var selectionRange: NSRange {
        return NSRange(location: start, length: length)
    }
}

// MARK: Client -> Server

struct UserCurserUpdatePackage: Codable {
    let packageID = SendPackageID.userCurserUpdate
    let start: Int
    let length: Int
    
    init(range: NSRange) {
        start = range.location
        length = range.length
    }
}
