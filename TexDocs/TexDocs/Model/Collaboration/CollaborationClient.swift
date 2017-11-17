//
//  CollaborationClient.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class CollaborationClient {
    private(set) var collaborationCursors: [String: CollaborationCursor] = [:]
    private(set) var userID: String?
    private(set) var repositoryURL: URL?
    
    weak var delegate: CollaborationClientDelegate?
    
    private let webSocket: WebSocket
    private var encounteredError: Bool = false
    
    func connect(to url: URL) {
        encounteredError = false
        webSocket.open(nsurl: url)
        webSocket.delegate = self
    }
    
    init() {
        webSocket = WebSocket()
    }
    
    deinit {
        webSocket.close()
    }
    
    private func connectionError(_ error: Error) {
        encounteredError = true
        webSocket.close()
        delegate?.collaborationClient(self, encounteredError: error)
    }
}

// MARK: Protocols

/// Collaboration Client Protocol
protocol CollaborationClientDelegate: class {
    func collaborationClient(_ client: CollaborationClient, encounteredError error: Error)
    func collaborationCursorsChanged(_ client: CollaborationClient)
    func collaborationClient(_ client: CollaborationClient, didConnectedAndReceivedRepositoryURL repositoryURL: URL)
    func collaborationClient(_ client: CollaborationClient, didReceivedChangeIn range: NSRange, replacedWith replaceString: String)
    func collaborationClient(_ client: CollaborationClient, didDisconnectedBecause reason: String)
}

// MARK: - Web Socket handler
extension CollaborationClient {
    func send<Package: Encodable>(package: Package) {
        do {
            try webSocket.send(data: JSONEncoder().encode(package))
        } catch {
            delegate?.collaborationClient(self, encounteredError: error)
        }
    }
    
    private func handleIncomingData(_ data: Data) throws {
        let jsonDecoder = JSONDecoder()
        let message: BasePackage
        
        do {
            message = try jsonDecoder.decode(BasePackage.self, from: data)
        } catch {
            connectionError(error)
            return
        }
        
        guard let packageID = message.type else {
            connectionError(CollaborationClientError.responseStatusCode(statusCode: message.status))
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
}

// MARK: - WebSocketDelegate
extension CollaborationClient: WebSocketDelegate {
    func webSocketOpen() {
        print("Web socket opened")
    }
    
    func webSocketClose(_ code: Int, reason: String, wasClean: Bool) {
        guard !encounteredError else { return }
        
        guard reason.count > 0 else {
            delegate?.collaborationClient(self, didDisconnectedBecause: NSLocalizedString("TD_ERROR_CONNECTION_LOST", comment: "Error message after unexpected connection drop."))
            return
        }
        delegate?.collaborationClient(self, didDisconnectedBecause: reason)
    }
    
    func webSocketError(_ error: NSError) {
        connectionError(error)
    }
    
    func webSocketMessageText(_ text: String) {
        print(text)
        guard let data = text.data(using: .utf8) else { return }
        
        // Dispatch to prevent the server closing the connection.
        DispatchQueue.main.async {
            do {
                try self.handleIncomingData(data)
            } catch {
                print(error)
            }
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

// MARK: - User Interaction
extension CollaborationClient {
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
}

// MARK: - Handle received packages
extension CollaborationClient {
    private func handleJoinPackage(_ package: ProjectJoinPackage) {
        self.userID = package.userID
        guard let url = URL(string: package.repositoryURL) else {
            connectionError(CollaborationClientError.receivedInvalidRepositoryURL(repositoryURLString: package.repositoryURL))
            return
        }
        self.repositoryURL = url
        delegate?.collaborationClient(self, didConnectedAndReceivedRepositoryURL: url)
    }
    
    private func handleCollaborationCursorUpdatePackage(_ package: CollaborationCursorUpdatePackage) {
        collaborationCursors[package.userID, default: CollaborationCursor.withRandomColor()].updateRange(package.selectionRange)
        delegate?.collaborationCursorsChanged(self)
    }
    
    private func handleCollaborationEditTextPackage(_ package: CollaborationEditTextPackage) {
        delegate?.collaborationClient(self, didReceivedChangeIn: package.range, replacedWith: package.replaceText)
    }
}
