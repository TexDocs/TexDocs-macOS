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
    var isSelected = false {
        didSet {
            if let controlView = controlView {
                controlView.setNeedsDisplay(controlView.bounds)
            }
        }
    }

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
        return NSSize(width: text.size().width + 2 * xSpacing, height: UserDefaults.editorFontSize.value)
    }

    override func cellBaselineOffset() -> NSPoint {
        return NSPoint(x: 0, y: UserDefaults.editorFont!.descender + deltaHeight / 2)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        if isSelected {
            NSColor.selectedMenuItemColor.set()
        } else {
            NSColor.lightGray.set()
        }

        let drawRect = NSRect.init(x: cellFrame.minX, y: cellFrame.minY, width: cellFrame.width, height: cellFrame.height + deltaHeight / 2)
        NSBezierPath(roundedRect: drawRect, xRadius: 5, yRadius: 5).fill()
        text.draw(at: NSPoint(x: cellFrame.minX + xSpacing, y: cellFrame.minY - deltaHeight / 2))
    }

    override func trackMouse(with theEvent: NSEvent, in cellFrame: NSRect, of controlView: NSView?, untilMouseUp flag: Bool) -> Bool {
        _ = super.trackMouse(with: theEvent, in: cellFrame, of: controlView, untilMouseUp: flag)
        isSelected = true
        controlView?.setNeedsDisplay(cellFrame)
        return false
    }

    private var deltaHeight: CGFloat {
        return text.size().height - cellSize().height
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
        _ = createTokens(in: NSRange(string.startIndex..<string.endIndex, in: string))
    }

    func createTokens(in range: NSRange) -> Int {
        let matches = EditorPlaceHolderRegex.matches(in: string, options: [], range: range)
        var shift = 0

        for match in matches {
            let range = match.range.shifted(by: -shift)
            let nameRange = match.range(at: 1).shifted(by: -shift)
            shift += match.range.length - 1
            let tokenCell = TokenCell(text: string[nameRange])
            let attachment = NSTextAttachment(data: nil, ofType: nil)
            attachment.attachmentCell  = tokenCell
            let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
            attributedString.addAttribute(.font, value: UserDefaults.editorFont!, range: NSRange(location: 0, length: 1))
            replaceCharacters(in: range, with: attributedString)
        }
        return -shift
    }
}

extension NSRange {
    func shifted(by shift: Int) -> NSRange {
        return NSRange(location: location + shift, length: length)
    }
}
