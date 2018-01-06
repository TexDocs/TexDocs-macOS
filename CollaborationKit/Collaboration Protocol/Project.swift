//
//  Project.swift
//  CollaborationKit
//
//  Created by Noah Peeters on 06.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import MessagePack
import MessagePackKit

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
