//
//  PDFViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa
import Quartz

class PDFViewController: NSViewController {

    @IBOutlet weak var pdfView: PDFView!

    override func viewDidLoad() {
        pdfView.autoScales = true
        pdfView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    private func destinationOfCurrentPDF() -> (pageIndex: Int, point: NSPoint, zoom: CGFloat)? {
        guard let destination = pdfView.currentDestination,
            let page = destination.page,
            let document = pdfView.document else {
                return nil
        }

        return (pageIndex: document.index(for: page), point: destination.point, zoom: pdfView.scaleFactor)
    }

    func showPDF(withURL url: URL) {
        let oldDestination = destinationOfCurrentPDF()

        let pdf = PDFDocument(url: url)
        pdfView.document = pdf

        if let oldDestination = oldDestination, let page = pdf?.page(at: oldDestination.pageIndex) ?? pdf?.page(at: 0) {
            let point = NSPoint(x: oldDestination.point.x, y: oldDestination.point.y - pdfView.bounds.height / oldDestination.zoom / 2)
            let newDestination = PDFDestination(page: page, at: point)
            newDestination.zoom = oldDestination.zoom
            pdfView.go(to: newDestination)
        }
    }
    @IBAction func enterFullScreen(_ sender: Any) {
        pdfView.autoScales = true
    }

    @IBAction func goToPreviousPage(_ sender: Any) {
        pdfView.goToPreviousPage(sender)
    }

    @IBAction func goToNextPage(_ sender: Any) {
        pdfView.goToNextPage(sender)
    }
}
