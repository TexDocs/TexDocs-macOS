//
//  CollaborationClient.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import Foundation
import MessagePack

class CollaborationClient {
    private(set) var collaborationCursors: [String: CollaborationCursor] = [:]
    private(set) var sessionID: UUID?

    weak var delegate: CollaborationClientDelegate?

    private var webSocket: WebSocket?
    private var ignoreCloseReason: Bool = false

    func connect(to url: URL) {
        sessionID = nil
        ignoreCloseReason = false
        webSocket = WebSocket()
        webSocket?.open(nsurl: url)
        webSocket?.delegate = self
        delegate?.collaborationClientDidStartConnecting(self)
    }

    init(delegate: CollaborationClientDelegate) {
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
protocol CollaborationClientDelegate: class {
    func collaborationClientDidStartConnecting(_ client: CollaborationClient)
    func collaborationClientDidConnected(_ client: CollaborationClient)
    func collaborationClient(_ client: CollaborationClient, encounteredError error: Error)
    func collaborationClient(_ client: CollaborationClient, didDisconnectedBecause reason: String)
    func collaborationClientDidCompletedHandshake(_ client: CollaborationClient)
    func collaborationCursorsChanged(_ client: CollaborationClient)
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
        case .projectRequestErrorResponse:
            try handleProjectRequestErrorResponse(ProjectRequestErrorResponse(decode: data))
        }
    }
}

// MARK: - WebSocketDelegate
extension CollaborationClient: WebSocketDelegate {
    func webSocketOpen() {
        sendHandshake()
        delegate?.collaborationClientDidConnected(self)
    }

    func webSocketClose(_ code: Int, reason: String, wasClean: Bool) {
        guard !ignoreCloseReason else { return }

        guard reason.count > 0 else {
            delegate?.collaborationClient(self, didDisconnectedBecause: NSLocalizedString("TD_ERROR_CONNECTION_LOST", comment: "Error message after unexpected connection drop."))
            return
        }
        delegate?.collaborationClient(self, didDisconnectedBecause: reason)
    }

    func webSocketError(_ error: NSError) {
        guard !ignoreCloseReason else { return }

        connectionError(error)
    }

    func webSocketMessageData(_ data: Data) {
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
    func sendHandshake() {
        send(package: HandshakeRequest())
    }

    func sendProjectRequest(forUUID uuid: UUID) {
        send(package: ProjectRequest(uuid: uuid))
    }

    func closeConnection(reason: String) {
        ignoreCloseReason = true
        webSocket?.close()
        delegate?.collaborationClient(self, didDisconnectedBecause: reason)
    }
}

// MARK: - Package handling
extension CollaborationClient {
    private func handleHandshakeAcknowledgementResponse(_ response: HandshakeAcknowledgementResponse) {
        self.sessionID = response.sessionID
        delegate?.collaborationClientDidCompletedHandshake(self)
    }

    private func handleHandshakeErrorResponse(_ response: HandshakeErrorResponse) {
        closeConnection(reason: response.reason)
    }

    private func handleProjectRequestSuccessResponse(_ response: ProjectRequestSuccessResponse) {
        print(response.projectID)
        print(response.projectName)

        // TODO: Implement
    }

    private func handleProjectRequestErrorResponse(_ response: ProjectRequestErrorResponse) {
        closeConnection(reason: response.reason)
    }
}
