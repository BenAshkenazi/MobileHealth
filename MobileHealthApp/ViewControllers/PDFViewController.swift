//
//  PDFViewController.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 9/6/23.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
    var pdfView: PDFView!
    @IBOutlet var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a PDFView
        pdfView = PDFView(frame: view.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        // Add the PDFView as a subview
        view.addSubview(pdfView)
        
        view.bringSubviewToFront(closeButton)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)])

        // Load and display the PDF file
        if let pdfURL = Bundle.main.url(forResource: "CTCResourceGuide", withExtension: "pdf") {
            if let document = PDFDocument(url: pdfURL) {
                pdfView.document = document
            }
        }
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        // Dismiss the PDFViewController when the close button is tapped
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
