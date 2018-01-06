//
//  SourceCodeViewPlaceholders.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

//extension SourceCodeView {
//    @discardableResult func goToNextPlaceholder() -> Bool {
//        return goToNextPlaceholder(from: NSMaxRange(selectedRange()))
//    }
//
//    @discardableResult func goToNextPlaceholder(from location: Int) -> Bool {
//        let range = NSRange(location: location, length: nsString.length - location)
//
//        return goToFirstPlaceholder(inRange: range)
//    }
//
//    @discardableResult func goToFirstPlaceholder(inRange range: NSRange) -> Bool {
//        return selectPlaceholder(inRange: range, last: false)
//    }
//
//    @discardableResult func goToPreviousPlaceholder() -> Bool {
//        return goToLastPlaceholder(before: selectedRange().location)
//    }
//
//    @discardableResult func goToLastPlaceholder(before location: Int) -> Bool {
//        let range = NSRange(location: 0, length: location)
//
//        return goToLastPlaceholder(inRange: range)
//    }
//
//    @discardableResult func goToLastPlaceholder(inRange range: NSRange) -> Bool {
//        return selectPlaceholder(inRange: range, last: true)
//    }
//
//    private func selectPlaceholder(inRange range: NSRange, last reverse: Bool) -> Bool {
//        var returnValue = false
//        textStorage?.enumerateTokens(in: range, reverse: reverse) { token, tokenRange in
//            textStorage?.deselectAllTokens()
//            setSelectedRange(tokenRange)
//            token.isSelected = true
//            returnValue = true
//            return false
//        }
//        return returnValue
//    }
//}

let editorPlaceHolderOpen = "{#"
let editorPlaceHolderClose = "#}"
let editorPlaceHolderOpenRegex = NSRegularExpression.escapedPattern(for: editorPlaceHolderOpen)
let editorPlaceHolderCloseRegex = NSRegularExpression.escapedPattern(for: editorPlaceHolderClose)

// swiftlint:disable force_try
let editorPlaceHolderRegex = try! NSRegularExpression(pattern: "\(editorPlaceHolderOpenRegex)(.*?)\(editorPlaceHolderCloseRegex)", options: .caseInsensitive)
let editorParameterPlaceholder = "\(editorPlaceHolderOpen)parameters\(editorPlaceHolderClose)"
