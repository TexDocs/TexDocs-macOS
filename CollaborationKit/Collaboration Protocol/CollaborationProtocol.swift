//
//  CollaborationProtocol.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import MessagePackKit

protocol SendablePackage: MessagePackEncodable {
    var packageIdentifier: RequestPackageIdentifier { get }
}

// --- Structure ---
// 0bXXXXX___ = Group ID e.g. Handshake/Project/File
// 0b_____111 = Request
// 0b_____0XX = Response
// 0b_____1XX = Error (exclusive 0b_____111)

enum RequestPackageIdentifier: UInt8 {
    case handshakeRequest = 0b00000_111
    case projectRequest   = 0b00001_111
    case fileRequest      = 0b00010_111
}

enum ResponsePackageIdentifier: Int {
    // handshake
    case handshakeAcknowledgementResponse = 0b00000_000
    case handshakeAcknowledgementError    = 0b00000_100

    // project
    case projectRequestSuccessResponse    = 0b00001_000
    case projectRequestError              = 0b00001_100

    // user management
    case userJoindNotification            = 0b00011_000
    case userLeftNotification             = 0b00011_001
}
