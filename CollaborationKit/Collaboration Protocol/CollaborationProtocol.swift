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
