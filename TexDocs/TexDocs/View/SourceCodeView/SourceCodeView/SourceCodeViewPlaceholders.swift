//
//  SourceCodeViewPlaceholders.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension SourceCodeView {
    @discardableResult func goToNextPlaceholder() -> Bool {
        return goToNextPlaceholder(from: NSMaxRange(selectedRange()))
    }

    @discardableResult func goToNextPlaceholder(from location: Int) -> Bool {
        let range = NSRange(location: location, length: string.count - location)

        return goToFirstPlaceholder(inRange: range)
    }

    @discardableResult func goToFirstPlaceholder(inRange range: NSRange) -> Bool {

        guard let match = EditorPlaceHolderRegex.firstMatch(in: string, options: [], range: range) else {
            return false
        }

        self.setSelectedRange(match.range)
        self.showFindIndicator(for: match.range)
        return true
    }

    @discardableResult func goToPreviousPlaceholder() -> Bool {
        return goToLastPlaceholder(before: selectedRange().location)
    }

    @discardableResult func goToLastPlaceholder(before location: Int) -> Bool {
        let range = NSRange(location: 0, length: location)

        return goToLastPlaceholder(inRange: range)
    }

    @discardableResult func goToLastPlaceholder(inRange range: NSRange) -> Bool {

        guard let match = EditorPlaceHolderRegex.matches(in: string, options: [], range: range).last else {
            return false
        }

        self.setSelectedRange(match.range)
        self.showFindIndicator(for: match.range)
        return true
    }

    func placeholder(atPosition position: NSRange) -> NSRange? {
        let range = nsString.lineRange(for: position)
        var placeholderRange: NSRange? = nil

        EditorPlaceHolderRegex.enumerateMatches(in: string, options: [], range: range) { (result, _, stop) in
            guard let match = result else {
                return
            }
            guard Range(match.range)?.contains(position.location) ?? false else {
                return
            }

            placeholderRange = match.range
            stop.pointee = ObjCBool(true)
        }

        return placeholderRange
    }

    override func selectionRange(forProposedRange proposedCharRange: NSRange, granularity: NSSelectionGranularity) -> NSRange {

        guard let placeholder = placeholder(atPosition: proposedCharRange) else {
            return super.selectionRange(forProposedRange: proposedCharRange, granularity: granularity)
        }

        showFindIndicator(for: placeholder)

        return placeholder
    }
}

let EditorPlaceHolderOpen = "{#"
let EditorPlaceHolderClose = "#}"
let EditorPlaceHolderOpenRegex = NSRegularExpression.escapedPattern(for: EditorPlaceHolderOpen)
let EditorPlaceHolderCloseRegex = NSRegularExpression.escapedPattern(for: EditorPlaceHolderClose)
let EditorPlaceHolderRegex = try! NSRegularExpression(pattern: "(\(EditorPlaceHolderOpenRegex).*?\(EditorPlaceHolderCloseRegex))", options: .caseInsensitive)
let EditorParameterPlaceholder = "\(EditorPlaceHolderOpen)paramters\(EditorPlaceHolderClose)"
