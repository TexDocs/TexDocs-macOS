//
//  MessagePackCodable.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import Foundation
import MessagePack

// MARK: - Encodable
public protocol MessagePackEncodable {
    var values: [MessagePackValuePrimitive] { get }
}

extension MessagePackEncodable {
    public func encode() -> Data {
        return pack(.array(values.map { $0.messagePackValue }))
    }
}

// MARK: - Decodable
public protocol MessagePackDecodable {
    init(from values: [MessagePackValue]) throws
}

public extension MessagePackDecodable {
    public init(decode packedData: Data) throws {
        try self.init(from: (unpackAll(packedData).first?.arrayValue).unwrap())
    }
}

// MARK: - Codable
public protocol MessagePackCodable: MessagePackEncodable, MessagePackDecodable {}

// MARK: - Helpers
public enum MessagePackError: Error {
    case unwrapFailed
    case arrayIndexDoesNotExists
}

public extension Optional {
    public func unwrap() throws -> Wrapped {
        guard let wrapped = self else {
            throw MessagePackError.unwrapFailed
        }
        return wrapped
    }
}

extension MessagePackValue {
    public var uuidValue: UUID? {
        guard let uuidString = stringValue else { return nil }

        return UUID(uuidString: uuidString)
    }
}

extension Array where Element == MessagePackValue {
    public func at(_ index: Int) throws -> MessagePackValue {
        guard count > index else {
            throw MessagePackError.arrayIndexDoesNotExists
        }
        return self[index]
    }
}
