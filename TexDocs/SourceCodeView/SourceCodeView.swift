//
//  SourceCodeView.swift
//  SourceCodeView
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class SourceCodeView: ImprovedTextView {
    
    //MARK: Line numbers
    
    private var lineNumberRuler: SourceCodeRulerView!
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        setUpLineNumberRuler()
    }
    
    private func setUpLineNumberRuler() {
        if let enclosingScrollView = enclosingScrollView {
            enclosingScrollView.hasHorizontalRuler = false
            enclosingScrollView.hasVerticalRuler = true
            let ruler = SourceCodeRulerView(sourceCodeView: self)
            lineNumberRuler = ruler
            enclosingScrollView.verticalRulerView = ruler
            enclosingScrollView.rulersVisible = true
        }
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        lineNumberRuler.redrawLineNumbers()
    }
    
    override func textDidChange(in range: NSRange, replacementString: String) {
        super.textDidChange(in: range, replacementString: replacementString)
        lineNumberRuler?.redrawLineNumbers()
    }
}
