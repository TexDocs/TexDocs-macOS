//
//  MessagePackValuePrimitive.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import MessagePack

/// Bridges Swift values to Message pack values
public protocol MessagePackValuePrimitive {
    var messagePackValue: MessagePackValue { get }
}

extension Int: MessagePackValuePrimitive {
    public var messagePackValue: MessagePackValue { return .int(Int64(self)) }
}

extension String: MessagePackValuePrimitive {
    public var messagePackValue: MessagePackValue { return .string(self) }
}

extension UUID: MessagePackValuePrimitive {
    public var messagePackValue: MessagePackValue { return .string(self.uuidString) }
}

extension MessagePackValue: MessagePackValuePrimitive {
    public var messagePackValue: MessagePackValue { return self }
}
