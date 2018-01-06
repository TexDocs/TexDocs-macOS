//
//  CollaborationClient.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import Foundation

public class CollaborationClient {
    private var collaborationUsers: [UUID: CollaborationUser] = [:]
    private var sessionUUID: UUID?
    private var webSocket: WebSocket?
    private var ignoreCloseReason: Bool = false

    public weak var delegate: CollaborationClientDelegate?

    public func connect(to url: URL) {
        sessionUUID = nil
        ignoreCloseReason = false
        webSocket = WebSocket()
        webSocket?.open(nsurl: url)
        webSocket?.delegate = self
        delegate?.collaborationClientDidStartConnecting(self)
    }

    public init(delegate: CollaborationClientDelegate) {
        self.delegate = delegate
    }

    deinit {
        webSocket?.close()
    }

    private func connectionError(_ error: Error) {
        webSocket?.close()
        webSocket = nil
        delegate?.collaborationClient(self, encounteredError: error)
    }
}

// MARK: - Protocols
/// Collaboration Client Protocol
public protocol CollaborationClientDelegate: class {
    func collaborationClientDidStartConnecting(_ client: CollaborationClient)
    func collaborationClientDidConnected(_ client: CollaborationClient)
    func collaborationClient(_ client: CollaborationClient, encounteredError error: Error)
    func collaborationClient(_ client: CollaborationClient, didDisconnectedBecause reason: String)
    func collaborationClientDidCompletedHandshake(_ client: CollaborationClient)
    func collaborationClient(_ client: CollaborationClient, userJoined user: CollaborationUser)
    func collaborationClient(_ client: CollaborationClient, userLeft user: CollaborationUser)
    func collaborationCursorsDidChanged(_ client: CollaborationClient)
}

extension CollaborationClient {
    private func send<Package: SendablePackage>(package: Package) {
        var encoded = package.encode()
        encoded.append(package.packageIdentifier.rawValue)
        webSocket?.send(data: encoded)
    }

    private func handleIncomingData(_ data: Data) throws {
        guard let rawPackageIdentifier = data.last,
            let packageIdentifier = ResponsePackageIdentifier(rawValue: Int(rawPackageIdentifier)) else {
            return
        }

        switch packageIdentifier {
        case .handshakeAcknowledgementResponse:
            try handleHandshakeAcknowledgementResponse(HandshakeAcknowledgementResponse(decode: data))
        case .handshakeAcknowledgementError:
            try handleHandshakeErrorResponse(HandshakeErrorResponse(decode: data))
        case .projectRequestSuccessResponse:
            try handleProjectRequestSuccessResponse(ProjectRequestSuccessResponse(decode: data))
        case .projectRequestError:
            try handleProjectRequestErrorResponse(ProjectRequestErrorResponse(decode: data))
        case .userJoindNotification:
            try handleUserJoindNotification(UserJoinedNotification(decode: data))
        case .userLeftNotification:
            try handleUserLeftNotification(UserLeftNotification(decode: data))
        }
    }
}

// MARK: - WebSocketDelegate
extension CollaborationClient: WebSocketDelegate {
    public func webSocketOpen() {
        sendHandshake()
        delegate?.collaborationClientDidConnected(self)
    }

    public func webSocketClose(_ code: Int, reason: String, wasClean: Bool) {
        guard !ignoreCloseReason else { return }

        guard reason.count > 0 else {
            delegate?.collaborationClient(self, didDisconnectedBecause: NSLocalizedString("TD_ERROR_CONNECTION_LOST", comment: "Error message after unexpected connection drop."))
            return
        }
        delegate?.collaborationClient(self, didDisconnectedBecause: reason)
    }

    public func webSocketError(_ error: NSError) {
        guard !ignoreCloseReason else { return }

        connectionError(error)
    }

    public func webSocketMessageData(_ data: Data) {
        // Dispatch to prevent the server closing the connection.
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try self.handleIncomingData(data)
            } catch {
                self.connectionError(error)
            }
        }
    }
}

// MARK: - Events
extension CollaborationClient {
    private func sendHandshake() {
        send(package: HandshakeRequest())
    }

    public func sendProjectRequest(forUUID uuid: UUID) {
        send(package: ProjectRequest(uuid: uuid))
    }

    public func closeConnection(reason: String) {
        ignoreCloseReason = true
        webSocket?.close()
        delegate?.collaborationClient(self, didDisconnectedBecause: reason)
    }
}

// MARK: - Package handling
extension CollaborationClient {
    private func handleHandshakeAcknowledgementResponse(_ response: HandshakeAcknowledgementResponse) {
        self.sessionUUID = response.sessionUUID
        delegate?.collaborationClientDidCompletedHandshake(self)
    }

    private func handleHandshakeErrorResponse(_ response: HandshakeErrorResponse) {
        closeConnection(reason: response.reason)
    }

    private func handleProjectRequestSuccessResponse(_ response: ProjectRequestSuccessResponse) {
        print(response.projectUUID)
        print(response.projectName)

        // TODO: Implement
    }

    private func handleProjectRequestErrorResponse(_ response: ProjectRequestErrorResponse) {
        closeConnection(reason: response.reason)
    }

    private func handleUserJoindNotification(_ notification: UserJoinedNotification) {
        // TODO set name and image
        let user = CollaborationUser(displayName: "Annonymous", sessionUUID: notification.sessionUUID)
        collaborationUsers[notification.sessionUUID] = user
        delegate?.collaborationClient(self, userJoined: user)
    }

    private func handleUserLeftNotification(_ notification: UserLeftNotification) {
        if let user = collaborationUsers.removeValue(forKey: notification.sessionUUID) {
            delegate?.collaborationClient(self, userLeft: user)
            delegate?.collaborationCursorsDidChanged(self)
        }
    }
}
