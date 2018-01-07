//
//  Handshake.swift
//  CollaborationKit
//
//  Created by Noah Peeters on 06.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import MessagePack
import MessagePackKit

struct HandshakeRequest: SendablePackage {
    let version = "0.1.1"
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
    let sessionUUID: UUID

    init(from values: [MessagePackValue]) throws {
        try sessionUUID = values.at(0).uuidValue.unwrap()
    }
}
