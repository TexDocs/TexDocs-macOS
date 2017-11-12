//
//  CollaborationClient.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class CollaborationClient: TCPClient {
    
    // MARK: Public interface
    private(set) var collaborationCursors: [String: CollaborationCursor] = [:] {
        didSet {
            delegate?.collaborationCursorsChanged(in: self)
        }
    }
    
    weak var delegate: CollaborationClientDelegate?
    
    override init() {
        super.init()
        connect()
    }
    
    // MARK: Private interface
    
    private func connect() {
        initNetworkCommunication(host: "localhost" as CFString, port: 8000)
    }
    
    private func connectionClosed() {
        collaborationCursors = [:]
    }
    
    // MARK: Callbacks
    
    override func onReceive(data: Data) {
        guard let message = String(data: data, encoding: .utf8) else {
            return
        }
        
        for jsonMessage in message.components(separatedBy: "\n") {
            print(jsonMessage)
        }
    }
    
    override func outputStreamOpened() {
        collaborationCursors = [
            UUID().uuidString: CollaborationCursor(range: NSRange(location: 10, length: 6), color: .red)
        ]
    }
    
    override func error() {
        connectionClosed()
    }
    
    override func closed() {
        connectionClosed()
    }
}

protocol CollaborationClientDelegate: class {
    func collaborationCursorsChanged(in client: CollaborationClient)
}
