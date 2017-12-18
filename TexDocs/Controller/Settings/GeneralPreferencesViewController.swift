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
    @IBOutlet weak var showControlCharactersButton: NSButton!
    @IBOutlet weak var themeSelector: NSPopUpButton!
    @IBOutlet weak var fontSelectButton: NSButton!
    @IBOutlet weak var latexPathTextField: LabeledTextField!
    @IBOutlet weak var latexdefPathTextField: LabeledTextField!
    @IBOutlet weak var texdocPathTextField: LabeledTextField!

    override func viewDidLoad() {
        showInvisibleCharactersButton.state = UserDefaults.showInvisibleCharacters.value ? .on : .off
        showControlCharactersButton.state = UserDefaults.showControlCharacters.value ? .on : .off
        latexPathTextField.value = UserDefaults.latexPath.value
        latexdefPathTextField.value = UserDefaults.latexdefPath.value
        texdocPathTextField.value = UserDefaults.texdocPath.value
        themeSelector.removeAllItems()
        themeSelector.addItems(withTitles: ThemesHandler.default.themeNames)
        themeSelector.selectItem(withTitle: UserDefaults.themeName.value)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFontButtonText),
            name: UserDefaults.editorFontName.notificationKey,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFontButtonText),
            name: UserDefaults.editorFontSize.notificationKey,
            object: nil)
        updateFontButtonText()
    }

    @objc func updateFontButtonText() {
        fontSelectButton.title = "\(UserDefaults.editorFontName.value), \(UserDefaults.editorFontSize.value)"
    }

    @IBAction func selectTheme(_ sender: Any) {
        if let newThemeName = themeSelector.selectedItem?.title {
            UserDefaults.themeName.value = newThemeName
        }
    }

    @IBAction func selectEditorFont(_ sender: Any) {
        NSFontManager.shared.target = self
        NSFontManager.shared.orderFrontFontPanel(sender)
        if let font = UserDefaults.editorFont {
            NSFontPanel.shared.setPanelFont(font, isMultiple: false)
        }
    }

    @IBAction func toggleShowInvisibleCharacters(_ sender: Any) {
        UserDefaults.showInvisibleCharacters.value = showInvisibleCharactersButton.state == .on
    }

    @IBAction func toggleShowControlCharacters(_ sender: Any) {
        UserDefaults.showControlCharacters.value = showControlCharactersButton.state == .on
    }

    override func changeFont(_ sender: Any?) {
        UserDefaults.updateFontFromFontPanel()
        updateFontButtonText()
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

    @IBAction func texdocPathChanged(_ sender: Any) {
        guard FileManager.default.fileExists(atPath: texdocPathTextField.value) else {
            texdocPathTextField.textView.textColor = .red
            return
        }
        texdocPathTextField.textView.textColor = .black
        UserDefaults.texdocPath.value = texdocPathTextField.value
    }


}
