//
//  GeneralPreferencesViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 11.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa
import LabeledTextField

class GeneralPreferencesViewController: NSViewController, CCNPreferencesWindowControllerProtocol {
    func preferenceIdentifier() -> String! {
        return "generalPreferences"
    }

    func preferenceTitle() -> String! {
        return NSLocalizedString("TD_PREFERENCS_TITLE_GENERAL", comment: "General preferences title")
    }

    func preferenceIcon() -> NSImage! {
        return NSImage(named: NSImage.Name(rawValue: "NSPreferencesGeneral"))
    }

    @IBOutlet weak var showInvisibleCharactersButton: NSButton!
    @IBOutlet weak var showControlleCharactersButton: NSButton!
    @IBOutlet weak var themeSelector: NSPopUpButton!
    @IBOutlet weak var latexPathTextField: LabeledTextField!
    @IBOutlet weak var latexdefPathTextField: LabeledTextField!

    override func viewDidLoad() {
        showInvisibleCharactersButton.state = UserDefaults.showInvisibleCharacters.value ? .on : .off
        showControlleCharactersButton.state = UserDefaults.showControlCharacters.value ? .on : .off
        latexPathTextField.value = UserDefaults.latexPath.value
        latexdefPathTextField.value = UserDefaults.latexdefPath.value
        themeSelector.removeAllItems()
        themeSelector.addItems(withTitles: ThemesHandler.default.themeNames)
        themeSelector.selectItem(withTitle: UserDefaults.themeName.value)
    }

    @IBAction func selectTheme(_ sender: Any) {
        if let newThemeName = themeSelector.selectedItem?.title {
            UserDefaults.themeName.value = newThemeName
        }
    }

    @IBAction func selectEditorFont(_ sender: Any) {
        NSFontManager.shared.target = self
        NSFontManager.shared.orderFrontFontPanel(sender)
    }

    @IBAction func toggleShowInvisibleCharacters(_ sender: Any) {
        UserDefaults.showInvisibleCharacters.value = showInvisibleCharactersButton.state == .on
    }

    override func changeFont(_ sender: Any?) {
        UserDefaults.updateFontFromFontPanel()
    }

    @IBAction func pdflatexPathChanged(_ sender: Any) {
        guard FileManager.default.fileExists(atPath: latexPathTextField.value) else {
            latexPathTextField.textView.textColor = .red
            return
        }
        latexPathTextField.textView.textColor = .black
        UserDefaults.latexPath.value = latexPathTextField.value
    }

    @IBAction func latexdefPathChanged(_ sender: Any) {
        guard FileManager.default.fileExists(atPath: latexdefPathTextField.value) else {
            latexdefPathTextField.textView.textColor = .red
            return
        }
        latexdefPathTextField.textView.textColor = .black
        UserDefaults.latexdefPath.value = latexdefPathTextField.value
    }

}
