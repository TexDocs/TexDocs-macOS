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
    var isSelected = false

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
        if isSelected {
            NSColor.selectedMenuItemColor.set()
        } else {
            NSColor.lightGray.set()
        }
        NSBezierPath(roundedRect: cellFrame, xRadius: 5, yRadius: 5).fill()
        text.draw(at: NSPoint(x: cellFrame.minX + xSpacing, y: cellFrame.minY + ySpacing))
    }

    override func trackMouse(with theEvent: NSEvent, in cellFrame: NSRect, of controlView: NSView?, untilMouseUp flag: Bool) -> Bool {
        _ = super.trackMouse(with: theEvent, in: cellFrame, of: controlView, untilMouseUp: flag)
        isSelected = true
        controlView?.setNeedsDisplay(cellFrame)
        return false
    }
}


extension NSTextStorage {
    func enumerateTokens(in range: NSRange, reverse: Bool = false, block: (TokenCell, NSRange) -> Bool) {
        let options = reverse ? NSAttributedString.EnumerationOptions.reverse : []

        enumerateAttribute(
            .attachment,
            in: range,
            options: options) { attachment, range, stop in
                if let attachment = attachment as? NSTextAttachment,
                    let token = attachment.attachmentCell as? TokenCell {
                    stop.pointee = ObjCBool(!block(token, range))
                }
        }
    }

    func deselectAllTokens() {
        enumerateTokens(in: NSRange(location: 0, length: length)) { token, _ in
            token.isSelected = false
            return true
        }
    }

    func removeAllTokens() {
        enumerateTokens(in: NSRange(location: 0, length: length)) { token, range in
            replaceCharacters(in: range, with: "{#\(token.text.string)#}", byUser: false)
            return true
        }
    }

    func createAllTokens() {
        createTokens(in: NSRange(string.startIndex..<string.endIndex, in: string))
    }

    func createTokens(in range: NSRange) {
        let matches = EditorPlaceHolderRegex.matches(in: string, options: [], range: range)

        for match in matches {
            let regexMatch = match.regularExpressionMatch(in: string)
            let tokenCell = TokenCell(text: regexMatch.captureGroups[1].string)
            let attachment = NSTextAttachment(data: nil, ofType: nil)
            attachment.attachmentCell  = tokenCell
            replaceCharacters(in: match.range, with: NSAttributedString(attachment: attachment))
        }
    }
}