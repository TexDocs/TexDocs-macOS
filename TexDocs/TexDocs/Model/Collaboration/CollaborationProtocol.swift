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
    case collaboratorEditText = "edit"
    case startSync = "startSync"
    case startUserSync = "startUserSync"
    case completedSync = "completedSync"
    case userDisconnected = "disconnect"
}

enum SendPackageID: String, Codable {
    case userCurserUpdate = "cursor"
    case userEditText = "edit"
    case startSync = "startSync"
    case completedUserSync = "completedUserSync"
}

struct BasePackage: Codable {
    let type: ReceivedPackgeID?
    let status: Int
}

// MARK: Server -> Client

struct ProjectJoinPackage: Codable {
    let userID: String
    let repositoryURL: String
    
    enum CodingKeys: String, CodingKey {
        case userID
        case repositoryURL = "repoURL"
    }
}

struct CollaborationCursorUpdatePackage: Codable {
    let userID: String
    let start: Int
    let length: Int
    let relativeFilePath: String
    
    var selectionRange: NSRange {
        return NSRange(location: start, length: length)
    }
}

struct CollaborationEditTextPackage: Codable {
    let start: Int
    let replaceLength: Int
    let replaceText: String
    let relativeFilePath: String
    
    var range: NSRange {
        return NSRange(location: start, length: replaceLength)
    }
}

struct CollaborationUserDisconnectedPackage: Codable {
    let userID: String
}

// MARK: Client -> Server

struct UserCurserUpdatePackage: Codable {
    let type = SendPackageID.userCurserUpdate
    let status = 200
    let start: Int
    let length: Int
    let relativeFilePath: String
    
    init(range: NSRange, inFile relativeFilePath: String) {
        self.relativeFilePath = relativeFilePath
        start = range.location
        length = range.length
    }
}

struct UserEditTextPackage: Codable {
    let type = SendPackageID.userEditText
    let status = 200
    let start: Int
    let replaceLength: Int
    let replaceText: String
    let relativeFilePath: String
    
    init(range: NSRange, replaceText: String, inFile relativeFilePath: String) {
        self.start = range.location
        self.replaceLength = range.length
        self.replaceText = replaceText
        self.relativeFilePath = relativeFilePath
    }
}

struct InitiateSyncPackage: Codable {
    let type = SendPackageID.startSync
    let status = 200
}

struct CompletedUserSyncPackage: Codable {
    let type = SendPackageID.completedUserSync
    let status = 200
}
