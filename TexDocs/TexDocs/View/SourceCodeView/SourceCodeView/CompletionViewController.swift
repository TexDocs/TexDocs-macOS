//
//  CompletionViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class CompletionViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!

    weak var delegateAndDataSource: CompletionViewControllerDelegate?

    override func viewDidLoad() {
        tableView.delegate = delegateAndDataSource
        tableView.dataSource = delegateAndDataSource
        tableView.refusesFirstResponder = true
    }

    @IBAction func doubleAction(_ sender: Any) {
        delegateAndDataSource?.completionTableView(tableView, doubleClicked: tableView.selectedRow)
    }
}

protocol CompletionViewControllerDelegate: NSTableViewDelegate, NSTableViewDataSource {
    func completionTableView(_ tableView: NSTableView, doubleClicked row: Int)
}

