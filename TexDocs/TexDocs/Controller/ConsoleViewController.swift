//
//  ConsoleViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 04.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class ConsoleViewController: NSViewController {
    @IBOutlet weak var textView: NSTextView!

    @IBAction func clearButtonPressed(_ sender: Any) {
        clearConsole()
    }

    func clearConsole() {
        textView.string = ""
    }

    func addString(_ string: String) {
        textView.textStorage?.append(NSAttributedString(string: string))
        textView.scrollRangeToVisible(NSRange(location: textView.string.count, length: 0))
    }
}