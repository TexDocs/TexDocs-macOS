//
//  CollaborationProtocol.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import Foundation
import MessagePack
import MessagePackKit

protocol SendablePackage: MessagePackEncodable {
    var packageIdentifier: RequestPackageIdentifier { get }
}

enum RequestPackageIdentifier: UInt8 {
    case handshakeRequest = 0
    case projectRequest = 3
}

enum ResponsePackageIdentifier: Int {
    case handshakeAcknowledgementResponse = 1
    case handshakeAcknowledgementError = 2
    case projectRequestErrorResponse = 4
    case projectRequestSuccessResponse = 5
}

// MARK: - Handshake
struct HandshakeRequest: SendablePackage {
    let version = "0.1.0"
    let packageIdentifier: RequestPackageIdentifier = .handshakeRequest
    var values: [MessagePackValuePrimitive] { return [version] }
}

struct HandshakeErrorResponse: MessagePackDecodable {
    let reason: String

    init(from values: [MessagePackValue]) throws {
        try reason = values.at(0).stringValue.unwrap()
    }
}

struct HandshakeAcknowledgementResponse: MessagePackDecodable {
    let sessionID: UUID

    init(from values: [MessagePackValue]) throws {
        try sessionID = values.at(0).uuidValue.unwrap()
    }
}

// MARK: - Project Request
struct ProjectRequest: SendablePackage {
    let uuid: UUID
    let packageIdentifier: RequestPackageIdentifier = .projectRequest
    var values: [MessagePackValuePrimitive] { return [uuid] }
}

struct ProjectRequestErrorResponse: MessagePackDecodable {
    let reason: String

    init(from values: [MessagePackValue]) throws {
        try reason = values.at(0).stringValue.unwrap()
    }
}

struct ProjectRequestSuccessResponse: MessagePackDecodable {
    let projectID: UUID
    let projectName: String

    init(from values: [MessagePackValue]) throws {
        try projectID = values.at(0).uuidValue.unwrap()
        try projectName = values.at(1).stringValue.unwrap()
    }
}
