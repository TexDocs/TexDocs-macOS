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
    
    func send<Package: Encodable>(package: Package) {
        do {
            try webSocket.send(data: JSONEncoder().encode(package))
        } catch {
            print(error)
        }
    }
    
    func textDidChange(oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool, to newString: String) {
        if byUser {
            send(package: UserEditTextPackge(range: oldRange, replaceText: newString))
        }
        
        collaborationCursors = collaborationCursors.mapValues { cursor in
            let cursorMax = NSMaxRange(cursor.range)
            let changeMax = NSMaxRange(oldRange)
            let newChangeMax = NSMaxRange(newRange)
            
            if cursor.range.location <= oldRange.location {       // cursor starts in front of the change
                if cursorMax <= oldRange.location {               // cursor ends in front of the change
                    return cursor
                } else if oldRange.contains(cursorMax) {          // cursor ends in change
                    return cursor.withLenght(oldRange.location - cursor.range.location)
                } else {                                          // cursor ends behind change
                    return cursor.withLenght(cursor.range.length + delta)
                }
            } else if oldRange.contains(cursor.range.location) {  // cursor starts in change
                if oldRange.contains(cursorMax) {                 // cursor ends in change
                    return cursor.with(NSRange(location: newChangeMax, length: 0))
                } else {                                          // cursor ends after change
                    return cursor.with(NSRange(location: newChangeMax, length: cursorMax - changeMax))
                }
            } else {                                              // cursor starts and ends after change
                return cursor.withDeltaLocation(delta)
            }
        }
    }
    
    func userSelectionDidChange(_ newSelection: NSRange) {
        send(package: UserCurserUpdatePackage(range: newSelection))
    }
    
    private func handleIncomingData(_ data: Data) throws {
        let jsonDecoder = JSONDecoder()

        let message = try jsonDecoder.decode(BasePackage.self, from: data)

        guard let packageID = message.type else {
            print(message.status)
            return
        }
        
        switch packageID {
        case .join:
            handleJoinPackage(try jsonDecoder.decode(ProjectJoinPackage.self, from: data))
        case .collaboratorCurserUpdate:
            handleCollaborationCursorUpdatePackage(try jsonDecoder.decode(CollaborationCursorUpdatePackage.self, from: data))
        case .collaboratorEditText:
            handleCollaborationEditTextPackage(try jsonDecoder.decode(CollaborationEditTextPackage.self, from: data))
        }
    }
    
    private func handleJoinPackage(_ package: ProjectJoinPackage) {
        self.userID = package.userID
        self.repoURL = package.repoURL
    }
    
    private func handleCollaborationCursorUpdatePackage(_ package: CollaborationCursorUpdatePackage) {
        self.collaborationCursors[package.userID, default: CollaborationCursor.withRandomColor()].updateRange(package.selectionRange)
        delegate?.collaborationCursorsChanged(in: self)
    }
    
    private func handleCollaborationEditTextPackage(_ package: CollaborationEditTextPackage) {
        delegate?.collaborationClient(receivedChangeIn: package.range, replacedWith: package.replaceText)
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
    func collaborationClient(receivedChangeIn range: NSRange, replacedWith replaceString: String)
}
