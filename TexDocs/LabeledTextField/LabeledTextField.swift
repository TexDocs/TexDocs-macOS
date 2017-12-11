//
//  LabeledTextField.swift
//  LabeledTextField
//
//  Created by Noah Peeters on 11.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

public class LabeledTextField: NSControl {

    public let textView = NSTextField()
    public let labelView = NSTextField(labelWithString: "")

    @IBInspectable public var title: String {
        get {
            return labelView.stringValue
        }
        set {
            labelView.stringValue = newValue
        }
    }

    @IBInspectable public var value: String {
        get {
            return textView.stringValue
        }
        set {
            textView.stringValue = newValue
        }
    }

    public override var action: Selector? {
        get {
            return textView.action
        }
        set {
            textView.action = newValue
        }
    }

    public override var target: AnyObject? {
        get {
            return textView.target
        }
        set {
            textView.target = newValue
        }
    }

    public init() {
        super.init(frame: NSRect.zero)
        setUp()
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setUp()
    }

    private func setUp() {
        addSubview(labelView)
        addSubview(textView)

        labelView.alignment = .right
        labelView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        labelView.firstBaselineAnchor.constraint(equalTo: textView.firstBaselineAnchor).isActive = true
        labelView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        labelView.rightAnchor.constraint(equalTo: textView.leftAnchor, constant: -8).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        textView.widthAnchor.constraint(equalTo: labelView.widthAnchor, multiplier: 4).isActive = true
    }
}
