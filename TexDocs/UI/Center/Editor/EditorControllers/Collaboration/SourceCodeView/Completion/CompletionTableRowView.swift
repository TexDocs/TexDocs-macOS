//
//  CompletionTableRowView.swift
//  TexDocs
//
//  Created by Noah Peeters on 06.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import Foundation

class CompletionTableRowView: NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {
        NSColor.selectedMenuItemColor.set()
        let path = NSBezierPath(rect: bounds)
        path.stroke()
        path.fill()
    }

    override var interiorBackgroundStyle: NSView.BackgroundStyle {
        if isSelected {
            return .dark
        } else {
            return .light
        }
    }
}
