//
//  EditorWindowController+Sheets.swift
//  TexDocs
//
//  Created by Noah Peeters on 18.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController {
    private func showSheetIfRequired() {
        guard !sheetIsShown else {
            return
        }
        sheetIsShown = true
        window?.contentViewController?.presentViewControllerAsSheet(notificationSheet)
    }
    
    func closeSheet() {
        DispatchQueue.main.async { [weak self] in
            guard let unwrappedSelf = self, unwrappedSelf.sheetIsShown else {
                return
            }
            unwrappedSelf.sheetIsShown = false
            self?.notificationSheet.dismiss(self)
        }
    }
    
    private func showSheetStep(text: String, buttonTitle: String? = nil, progressBarValue: ProgressBarValue) {
        DispatchQueue.main.async { [weak self] in
            self?.showSheetIfRequired()
            self?.notificationSheet.updateLabel(text: text)
            self?.notificationSheet.updateButton(title: buttonTitle)
            self?.notificationSheet.updateProgressBar(value: progressBarValue)
        }
    }
    
    func showUserNotificationSheet(text: String, action: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.showSheetIfRequired()
            self?.notificationSheet.updateLabel(text: text)
            self?.notificationSheet.updateButton(title: NSLocalizedString("TD_BUTTON_CLOSE", comment: "Button title of notification sheets.")) {
                self?.closeSheet()
                action?()
            }
            self?.notificationSheet.updateProgressBar(value: .hidden)
        }
    }
    
    private func showErrorClosingSheet(text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.showSheetIfRequired()
            self?.notificationSheet.updateLabel(text: text)
            self?.notificationSheet.updateProgressBar(value: .hidden)
            self?.notificationSheet.updateButton(title: NSLocalizedString("TD_BUTTON_CLOSE_PROJECT", comment: "Button title of error sheets.")) {
                self?.close()
            }
        }
    }
}

extension EditorWindowController {
    func showErrorSheet(_ error: Error) {
        showErrorClosingSheet(text: error.localizedDescription)
    }
    
    func showErrorSheet(withCustomMessage text: String) {
        showErrorClosingSheet(text: text)
    }
    
    func showInternalErrorSheet() {
        showErrorClosingSheet(
            text: NSLocalizedString(
                "TD_ERROR_INTERNAL_ERROR",
                comment: "Message shown to the user if an internal error occures.")
        )
    }
    
    func showMissmatchedURLReceivedSheet() {
        showErrorClosingSheet(
            text: NSLocalizedString(
                "TD_ERROR_MISSMATCHED_REPOSITORY_URL",
                comment: "Message shown to the user if the saved and the received repository url don't match.")
        )
    }
    
    func showConnectingSheet() {
        showSheetStep(
            text: NSLocalizedString(
                "TD_NOTIFICATION_CONNECTING_TO_SERVER",
                comment: "Message shown to the user while connecting to the server."),
            progressBarValue: .indeterminate
        )
    }
    
    func showCloningSheet() {
        showSheetStep(
            text: NSLocalizedString(
                "TD_NOTIFICATION_CLONING_REPOSITORY",
                comment: "Message shown to the user while starting the cloning."),
            progressBarValue: .indeterminate
        )
    }
    
    func showCloningProgressSheet(total: UInt32, completed: UInt32) {
        let text = NSLocalizedString(
            "TD_NOTIFICATION_RECEIVING_OBJECTS",
            comment: "Shown while receiving objects from git remote.")
        
        showSheetStep(
            text: "\(text) (\(completed)/\(total))",
            progressBarValue: .value(Double(completed)/Double(total))
        )
    }
    
    func showCloningCompletedSheet(action: (() -> Void)? = nil) {
        showUserNotificationSheet(
            text: NSLocalizedString(
                "TD_NOTIFICATION_REPOSITORY_CLONED",
                comment: "Notification for the user after a successfull clone."),
            action: action)
    }
    
    func showPullingProgressSheet(total: UInt32, completed: UInt32) {
        let text = NSLocalizedString(
            "TD_NOTIFICATION_PULLING_PROGRESS",
            comment: "Shown while pulling from git remote.")
        
        showSheetStep(
            text: "\(text) (\(completed)/\(total))",
            progressBarValue: .value(Double(completed)/Double(total))
        )
    }
    
    func showFetchProgressSheet(total: UInt32, completed: UInt32) {
        let text = NSLocalizedString(
            "TD_NOTIFICATION_FETCH_PROGRESS",
            comment: "Shown while fetching from git remote.")
        
        showSheetStep(
            text: "\(text) (\(completed)/\(total))",
            progressBarValue: .value(Double(completed)/Double(total))
        )
    }
    
    func showPushingProgressSheet(total: UInt32, completed: UInt32) {
        let text = NSLocalizedString(
            "TD_NOTIFICATION_PUSHING_PROGRESS",
            comment: "Shown while pushing to git remote.")
        
        showSheetStep(
            text: "\(text) (\(completed)/\(total))",
            progressBarValue: .value(Double(completed)/Double(total))
        )
    }
    
    func showScheduledSyncSheet() {
        showSheetStep(
            text: NSLocalizedString(
                "TD_NOTIFICATION_REQUESTED_SYNC",
                comment: "Notification for the user while waiting for a sync start package."),
            progressBarValue: .indeterminate)
    }
    
    func showSyncStartedSheet() {
        showSheetStep(
            text: NSLocalizedString(
                "TD_NOTIFICATION_WAITING_FOR_SYNC_TO_START",
                comment: "Notification for the user while waiting for the own sync to start."),
            progressBarValue: .indeterminate)
    }
    
    func showCompletedUserSyncSheet() {
        showSheetStep(
            text: NSLocalizedString(
                "TD_NOTIFICATION_WAITING_FOR_SYNC_TO_COMPLETE",
                comment: "Notification for the user while waiting for the sync to complete."),
            progressBarValue: .indeterminate)
    }
    
    func showPullingStartedSheet() {
        showSheetStep(
            text: NSLocalizedString(
                "TD_NOTIFICATION_STARTED_PULLING",
                comment: "Notification for the user after pull started."),
            progressBarValue: .indeterminate)
    }
}


extension EditorWindowController: EditSchemeSheetDelegate {
    func schemeUpdated() {
        editedDocument()
        reloadSchemeSelector()
    }
}
