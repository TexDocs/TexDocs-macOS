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
    
}


extension EditorWindowController: EditSchemeSheetDelegate {
    func schemeUpdated() {
        editedDocument()
        reloadSchemeSelector()
    }
}
