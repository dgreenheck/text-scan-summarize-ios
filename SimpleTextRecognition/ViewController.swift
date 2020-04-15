/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller that invokes the VisionKit document camera, and performs a VNRecognizeTextRequest on the scanned document.
*/

import UIKit
import Vision
import VisionKit
import Reductio

class ViewController: UIViewController {
    
    @IBOutlet weak var scannedTextView: UITextView!
    @IBOutlet weak var summaryTextView: UITextView!
    
    // Vision requests to be performed on each page of the scanned document.
    private var requests = [VNRequest]()
    // Dispatch queue to perform Vision requests.
    private let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                         qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    private var resultingText = ""
    
    // Setup Vision request as the request can be reused
    private func setupVision() {
        let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("The observations are of an unexpected type.")
                return
            }
            // Concatenate the recognised text from all the observations.
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                self.resultingText += candidate.string + "\n"
            }
        }
        // specify the recognition level
        textRecognitionRequest.recognitionLevel = .accurate
        self.requests = [textRecognitionRequest]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupVision()
    }
    
    @IBAction func scanReceipts(_ sender: UIControl?) {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
}

// MARK: VNDocumentCameraViewControllerDelegate

extension ViewController: VNDocumentCameraViewControllerDelegate {
    
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // Clear any existing text.
        scannedTextView?.text = ""
        // dismiss the document camera
        controller.dismiss(animated: true)
        
        textRecognitionWorkQueue.async {
            self.resultingText = ""
            for pageIndex in 0 ..< scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                if let cgImage = image.cgImage {
                    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    
                    do {
                        try requestHandler.perform(self.requests)
                    } catch {
                        print(error)
                    }
                }
                self.resultingText += "\n\n"
                self.resultingText = self.resultingText.replacingOccurrences(of: "\n", with: " ")
            }
            DispatchQueue.main.async {
                print(self.resultingText)
                self.scannedTextView.text = self.resultingText
                Reductio.summarize(text: self.resultingText, compression: 0.8) {(phrases) in
                    print(phrases)
                    self.summaryTextView.text = phrases.reduce("") { $0 + $1 }
                }
            }
        }

    }
}
