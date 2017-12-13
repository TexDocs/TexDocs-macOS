//
//  TokenCell.swift
//  TexDocs
//
//  Created by Noah Peeters on 13.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class TokenCell: NSTextAttachmentCell {
    let text: NSMutableAttributedString
    let xSpacing: CGFloat = 3
    let ySpacing: CGFloat = 0
    var selected = false

    init(text: String) {
        self.text = NSMutableAttributedString(string: text, attributes: [
            NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            ])
        super.init()

        updateFont()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFont),
            name: UserDefaults.editorFontName.notificationKey,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFont),
            name: UserDefaults.editorFontSize.notificationKey,
            object: nil)
    }

    @objc func updateFont() {
        guard let font = UserDefaults.editorFont else {
            return
        }
        text.addAttribute(
            NSAttributedStringKey.font,
            value: font,
            range: NSRange(location: 0, length: text.length))
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func wantsToTrackMouse() -> Bool {
        return true
    }

    override func cellSize() -> NSSize {
        return NSSize(width: text.size().width + 2 * xSpacing, height: text.size().height + 2 * ySpacing)
    }

    override func cellBaselineOffset() -> NSPoint {
        return NSPoint(x: 0, y: UserDefaults.editorFont!.descender - ySpacing)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        if selected {
            NSColor.selectedMenuItemColor.set()
        } else {
            NSColor.lightGray.set()
        }
        NSBezierPath(roundedRect: cellFrame, xRadius: 5, yRadius: 5).fill()
        text.draw(at: NSPoint(x: cellFrame.minX + xSpacing, y: cellFrame.minY + ySpacing))
    }

    override func trackMouse(with theEvent: NSEvent, in cellFrame: NSRect, of controlView: NSView?, untilMouseUp flag: Bool) -> Bool {
        _ = super.trackMouse(with: theEvent, in: cellFrame, of: controlView, untilMouseUp: flag)
        selected = true
        controlView?.setNeedsDisplay(cellFrame)
        return false
    }
}

