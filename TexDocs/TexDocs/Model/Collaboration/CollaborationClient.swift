//
//  CollaborationClient.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation
import SwiftWebSocket

class CollaborationClient {
    
    // MARK: Public interface
    weak var delegate: CollaborationClientDelegate?
    
    private(set) var collaborationCursors: [String: CollaborationCursor] = [:] {
        didSet {
            delegate?.collaborationCursorsChanged(in: self)
        }
    }
    
    private(set) var userID: String?
    private(set) var repoURL: String?
    var userName: String = ""
    
    private let webSocket: WebSocket
    
    init(url: URL) {
        webSocket = WebSocket(url: url)
        webSocket.delegate = self
    }
    
    private func handleIncomingData(_ data: Data) throws {
        let jsonDecoder = JSONDecoder()
        
        guard let message = try? jsonDecoder.decode(BasePackage.self, from: data) else {
            return
        }
        
        guard let packageID = message.packageID else {
            print(message.statusCode)
            return
        }
        
        switch packageID {
        case .join:
            handleJoinPackage(try jsonDecoder.decode(ProjectJoinPackage.self, from: data))
        }
    }
    
    private func handleJoinPackage(_ package: ProjectJoinPackage) {
        self.userID = package.userID
        self.repoURL = package.repoURL
    }
}

extension CollaborationClient: WebSocketDelegate {
    func webSocketOpen() {
        self.collaborationCursors = [
            UUID().uuidString: CollaborationCursor(range: NSRange(location: 10, length: 6), color: .red)
        ]
    }
    
    func webSocketClose(_ code: Int, reason: String, wasClean: Bool) {
        self.webSocket.open()
    }
    
    func webSocketError(_ error: NSError) {
        print(error)
    }
    
    func webSocketMessageText(_ text: String) {
        print(text)
        guard let data = text.data(using: .utf8) else { return }
        
        do {
            try handleIncomingData(data)
        } catch {
            print(error)
        }
            
    }
    
    func webSocketMessageData(_ data: Data) {
        do {
            try handleIncomingData(data)
        } catch {
            print(error)
        }
    }
    
    func webSocketPong() {
        print("pong received")
    }
    
}

protocol CollaborationClientDelegate: class {
    func collaborationCursorsChanged(in client: CollaborationClient)
}
