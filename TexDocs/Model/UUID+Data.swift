//
//  UUID+Data.swift
//  TexDocs
//
//  Created by Noah Peeters on 06.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import Foundation

extension UUID {
    init(data: Data) {
        self.init(uuid: (data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]))
    }

    var data: Data {
        return Data(bytes: [uuid.0, uuid.1, uuid.2, uuid.3, uuid.4, uuid.5, uuid.6, uuid.7, uuid.8, uuid.9, uuid.10, uuid.11, uuid.12, uuid.13, uuid.14, uuid.15])
    }
}
