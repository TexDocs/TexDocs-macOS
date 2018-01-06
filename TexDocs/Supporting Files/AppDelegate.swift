//
//  AppDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let preferences = CCNPreferencesWindowController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        preferences.centerToolbarItems = false
        preferences.setPreferencesViewControllers([
            GeneralPreferencesViewController(),
            VCSPreferencesViewController()
        ])
    }

    @IBAction func showPreferencesWindow(_ sender: Any) {
        preferences.showPreferencesWindow()
    }
}

