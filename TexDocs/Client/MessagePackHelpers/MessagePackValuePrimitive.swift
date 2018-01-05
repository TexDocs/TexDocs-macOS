//
//  MessagePackValuePrimitive.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import MessagePack

protocol MessagePackValuePrimitive {
    var messagePackValue: MessagePackValue { get }
}

extension Int: MessagePackValuePrimitive {
    var messagePackValue: MessagePackValue { return .int(Int64(self)) }
}

extension String: MessagePackValuePrimitive {
    var messagePackValue: MessagePackValue { return .string(self) }
}

extension UUID: MessagePackValuePrimitive {
    var messagePackValue: MessagePackValue { return .string(self.uuidString) }
}

extension MessagePackValue: MessagePackValuePrimitive {
    var messagePackValue: MessagePackValue { return self }
}
