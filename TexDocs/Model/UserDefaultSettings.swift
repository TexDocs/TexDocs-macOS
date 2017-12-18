//
//  UserDefaultSettings.swift
//  TexDocs
//
//  Created by Noah Peeters on 11.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class UserDefaultSettings<Value: Equatable> {
    let key: String
    let notificationKey: NSNotification.Name
    private let defaultValue: Value

    init(key: String, notificationKey: String? = nil, default defaultValue: Value) {
        self.key = key
        self.notificationKey = NSNotification.Name(rawValue: "UserDefaults-\(notificationKey ?? key)")
        self.defaultValue = defaultValue
    }

    var value: Value {
        get {
            return UserDefaults.standard.value(forKey: key) as? Value ?? defaultValue
        }
        set {
            if value != newValue {
                UserDefaults.standard.set(newValue, forKey: key)
                NotificationCenter.default.post(name: notificationKey, object: self)
            }
        }
    }
}


extension UserDefaults {
    static let showInvisibleCharacters = UserDefaultSettings<Bool>(key: "showInvisibleCharacters", default: false)
    static let showControlCharacters = UserDefaultSettings<Bool>(key: "showControlCharacters", default: false)
    static let themeName = UserDefaultSettings<String>(key: "themeName", default: "Default")
    static let editorFontName = UserDefaultSettings<String>(key: "editorFontName", default: "Menlo")
    static let editorFontSize = UserDefaultSettings<CGFloat>(key: "editorFontSize", default: 12)
    static let latexPath = UserDefaultSettings<String>(key: "latexPath", default: "/Library/TeX/texbin/pdflatex")
    static let latexdefPath = UserDefaultSettings<String>(key: "latexdefPath", default: "/Library/TeX/texbin/latexdef")
    static let texdocPath = UserDefaultSettings<String>(key: "texdocPath", default: "/Library/TeX/texbin/texdoc")
    static let publicKeyPath = UserDefaultSettings<String>(key: "publicKeyPath", default: "~/.ssh/id_rsa.pub")
    static let privateKeyPath = UserDefaultSettings<String>(key: "privateKeyPath", default: "~/.ssh/id_rsa")
    static let gitName = UserDefaultSettings<String>(key: "gitName", default: "Anonymous")
    static let gitEMail = UserDefaultSettings<String>(key: "gitEMail", default: "Anonymous@example.com")

    static var editorFont: NSFont? {
        return NSFont(name: UserDefaults.editorFontName.value, size: UserDefaults.editorFontSize.value)
    }

    static func updateFontFromFontPanel() {
        let font = NSFontPanel.shared.convert(NSFont.systemFont(ofSize: NSFont.systemFontSize))
        UserDefaults.editorFontName.value = font.fontName
        UserDefaults.editorFontSize.value = font.pointSize
    }
}
