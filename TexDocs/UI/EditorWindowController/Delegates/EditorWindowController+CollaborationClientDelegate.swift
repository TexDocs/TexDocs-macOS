//
//  EditorWindowController+CollaborationClientDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import Foundation
import CollaborationKit

extension EditorWindowController: CollaborationClientDelegate {
    func collaborationClientDidStartConnecting(_ client: CollaborationClient) {
        updateConnectionStatus(.connecting)
    }

    func collaborationClientDidConnected(_ client: CollaborationClient) {
        updateConnectionStatus(.connected)
    }

    func collaborationClient(_ client: CollaborationClient, encounteredError error: Error) {
        showErrorSheet(error)
        updateConnectionStatus(.disconnected)
    }

    func collaborationClient(_ client: CollaborationClient, didDisconnectedBecause reason: String) {
        showUserNotificationSheet(text: reason)
        updateConnectionStatus(.disconnected)
    }

    func collaborationClientDidCompletedHandshake(_ client: CollaborationClient) {
        guard let projectID = workspace?.workspaceModel.serverProjectUUID else {
            client.closeConnection(reason: NSLocalizedString("TD_NO_PROJECT_ID", comment: "Project id not found."))
            return
        }

        client.sendProjectRequest(forUUID: projectID)
    }

    func collaborationCursorsChanged(_ client: CollaborationClient) {
        //TODO implement
    }

    func updateConnectionStatus(_ newStatus: ConnectionState) {
        DispatchQueue.main.async {
            self.connectionStatusToolbarItem.image = NSImage(named: NSImage.Name(rawValue: newStatus.rawValue))
        }
    }
}

enum ConnectionState: String {
    case unknown = "NSImageNameStatusNone"
    case connected = "NSStatusAvailable"
    case disconnected = "NSStatusUnavailable"
    case connecting = "NSStatusPartiallyAvailable"
}
