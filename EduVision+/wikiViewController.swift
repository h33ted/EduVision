import UIKit
import Vision
import VisionKit

class wikiViewController: UIViewController {
    
    private var scanButton = ScanButton(frame: .zero)
    private var summaryTextView = UITextView(frame: .zero)
    private var wikiLinksTableView = UITableView()
    private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    private var wikiLinks: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureOCR()
        configureTableView()
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        view.addSubview(summaryTextView)
        view.addSubview(wikiLinksTableView)
        view.addSubview(scanButton)

        summaryTextView.translatesAutoresizingMaskIntoConstraints = false
        wikiLinksTableView.translatesAutoresizingMaskIntoConstraints = false

        let padding: CGFloat = 16
        NSLayoutConstraint.activate([
            scanButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            scanButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            scanButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            scanButton.heightAnchor.constraint(equalToConstant: 50),

            wikiLinksTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            wikiLinksTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            wikiLinksTableView.bottomAnchor.constraint(equalTo: scanButton.topAnchor, constant: -padding),
            wikiLinksTableView.heightAnchor.constraint(equalToConstant: 200),

            summaryTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            summaryTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            summaryTextView.bottomAnchor.constraint(equalTo: wikiLinksTableView.topAnchor, constant: -padding),
            summaryTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
        ])

        scanButton.addTarget(self, action: #selector(scanDocument), for: .touchUpInside)
    }

    @objc private func scanDocument() {
        let scanVC = VNDocumentCameraViewController()
        scanVC.delegate = self
        present(scanVC, animated: true)
    }
    
    private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        summaryTextView.text = ""
        scanButton.isEnabled = false
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch {
            print(error)
        }
    }
    
    private func configureOCR() {
        ocrRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var ocrText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                
                ocrText += topCandidate.string + "\n"
            }
            
            DispatchQueue.main.async {
                self.sendPostRequest(ocrText: ocrText)
            }
        }
        
        ocrRequest.recognitionLevel = .accurate
        ocrRequest.recognitionLanguages = ["en-US", "en-GB", ""]
        ocrRequest.usesLanguageCorrection = true
    }
    
    private func configureTableView() {
        wikiLinksTableView.delegate = self
        wikiLinksTableView.dataSource = self
        wikiLinksTableView.register(UITableViewCell.self, forCellReuseIdentifier: "wikiLinkCell")
    }
    private func sendPostRequest(ocrText: String) {
        guard let url = URL(string: "http://192.168.31.141:8000/ocr") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestBodyString = "text=\(ocrText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = requestBodyString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        if let summary = jsonResponse["summary"] as? String {
                            self.summaryTextView.text = summary
                        }
                        
                        if let wikiLinks = jsonResponse["wikiLinks"] as? [String: String] {
                            self.wikiLinks = wikiLinks
                            self.wikiLinksTableView.reloadData()
                        }
                        
                        self.scanButton.isEnabled = true
                    }
                }
            } catch {
                print("Error decoding JSON response: \(error)")
            }
        }
        
        task.resume()
    }
}
extension wikiViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        processImage(scan.imageOfPage(at: 0))
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        //Handle properly error
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
}

extension wikiViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wikiLinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wikiLinkCell", for: indexPath)
        let key = Array(wikiLinks.keys)[indexPath.row]
        cell.textLabel?.text = key
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = Array(wikiLinks.keys)[indexPath.row]
        if let urlString = wikiLinks[key], let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

    
