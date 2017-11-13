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
}

enum SendPackageID: String, Codable {
    case userCurserUpdate = "cursor"
    case userEditText = "edit"
}

struct BasePackage: Codable {
    let type: ReceivedPackgeID?
    let status: Int
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

struct CollaborationEditTextPackage: Codable {
    let start: Int
    let replaceLength: Int
    let replaceText: String
    
    var range: NSRange {
        return NSRange(location: start, length: replaceLength)
    }
}

// MARK: Client -> Server

struct UserCurserUpdatePackage: Codable {
    let type = SendPackageID.userCurserUpdate
    let status = 200
    let start: Int
    let length: Int
    
    init(range: NSRange) {
        start = range.location
        length = range.length
    }
}

struct UserEditTextPackge: Codable {
    let type = SendPackageID.userEditText
    let status = 200
    let start: Int
    let replaceLength: Int
    let replaceText: String
    
    init(range: NSRange, replaceText: String) {
        self.start = range.location
        self.replaceLength = range.length
        self.replaceText = replaceText
    }
}
