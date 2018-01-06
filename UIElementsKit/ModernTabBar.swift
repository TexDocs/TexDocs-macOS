//
//  ModernTapBar.swift
//  TexDocs
//
//  Created by Noah Peeters on 09.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

public class ModernTabBar: NSStackView {
    public weak var tabBarDelegate: ModernTabBarDelegate?

    private var buttons: [NSButton] {
        return subviews.flatMap {
            $0 as? NSButton
        }
    }

    public var selectedButton: Int = 0 {
        didSet {
            buttons[oldValue].state = .off
            buttons[selectedButton].state = .on
            tabBarDelegate?.modernTabBar(self, didSelected: selectedButton)
        }
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)

        for button in buttons {
            button.action = #selector(buttonClicked(_:))
            button.target = self
        }
    }

    @objc func buttonClicked(_ button: NSButton) {
        guard button.state == .on else {
            button.state = .on
            return
        }
        selectedButton = buttons.index(of: button) ?? 0
    }
}

public protocol ModernTabBarDelegate: class {
    func modernTabBar(_ modernTabBar: ModernTabBar, didSelected buttonIndex: Int)
}
