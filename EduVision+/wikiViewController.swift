import UIKit
import Vision
import VisionKit
import SafariServices

class wikiViewController: UIViewController {
    
    private var scanButton = ScanButton(frame: .zero)
    private var summaryTextView = UITextView(frame: .zero)
    private var wikiLinksTableView = UITableView()
    private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    private var wikiLinks: [String: String] = [:]
    private var titleLabel = UILabel()  // The title label

    override func viewDidLoad() {
            super.viewDidLoad()
            
            adjustBackgroundColor()
            configure()
            configureOCR()
            configureTableView()
        }

        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            adjustBackgroundColor()
        }
        
        private func adjustBackgroundColor() {
            if self.traitCollection.userInterfaceStyle == .dark {
                // Dark Marine Blue color for Dark Mode
                view.backgroundColor = UIColor(red: 61/255, green: 43/255, blue: 31/255, alpha: 0.5)
            } else {
                // Light Color for Light Mode
                view.backgroundColor = UIColor(red: 239/255, green: 234/255, blue: 229/255, alpha: 1)
            }
        }
    
    private func configure() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
                titleLabel.text = "Learniverse"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight(30))
                titleLabel.textAlignment = .left
                view.addSubview(titleLabel)
        view.addSubview(summaryTextView)
        view.addSubview(wikiLinksTableView)
        view.addSubview(scanButton)

        summaryTextView.translatesAutoresizingMaskIntoConstraints = false
        wikiLinksTableView.translatesAutoresizingMaskIntoConstraints = false
        scanButton.translatesAutoresizingMaskIntoConstraints = false

        let padding: CGFloat = 16
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant:padding),
                        titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
                        titleLabel.bottomAnchor.constraint(equalTo: summaryTextView.topAnchor, constant: -10),  // put it on top of summaryTextView
            
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

        summaryTextView.backgroundColor = UIColor(red: 245/255, green: 222/255, blue: 179/255, alpha: 1.0)
        summaryTextView.textColor = .black
        summaryTextView.font = UIFont.systemFont(ofSize: 18)
        summaryTextView.layer.cornerRadius = 16
        summaryTextView.textContainerInset = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        summaryTextView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]

        wikiLinksTableView.layer.cornerRadius = 16
        wikiLinksTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        wikiLinksTableView.separatorColor = UIColor(red: 150/255, green: 111/255, blue: 51/255, alpha: 1.0)
        
        scanButton.addTarget(self, action: #selector(scanDocument), for: .touchUpInside)
    }

    private func configureTableView() {
        wikiLinksTableView.delegate = self
        wikiLinksTableView.dataSource = self
        wikiLinksTableView.register(UITableViewCell.self, forCellReuseIdentifier: "wikiLinkCell")
        wikiLinksTableView.backgroundColor = UIColor(red: 245/255, green: 222/255, blue: 179/255, alpha: 1.0)
        wikiLinksTableView.layer.cornerRadius = 16
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
                self.sendSummaryRequest(ocrText: ocrText)
                self.sendWikiRequest(ocrText: ocrText)
            }
        }
        
        ocrRequest.recognitionLevel = .accurate
        ocrRequest.recognitionLanguages = ["en-US", "en-GB", ""]
        ocrRequest.usesLanguageCorrection = true
    }
    
    
    private func sendSummaryRequest(ocrText: String) {
        guard let url = URL(string: "http://79.118.98.36:8000/summarize") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let requestBodyString = "text=\(ocrText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = requestBodyString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self?.summaryTextView.text = jsonResponse["response"] as? String ?? ""
                        self?.scanButton.isEnabled = true
                    }
                }
            } catch {
                print("JSON text was not in the correct format")
            }
        }
        task.resume()
    }

    private func sendWikiRequest(ocrText: String) {
        guard let url = URL(string: "http://79.118.98.36:8000/wiki") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let requestBodyString = "text=\(ocrText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = requestBodyString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                    DispatchQueue.main.async {
                        self?.wikiLinks = jsonResponse
                        self?.wikiLinksTableView.reloadData()
                    }
                }
            } catch {
                print("JSON text was not in the correct format")
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

extension wikiViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wikiLinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wikiLinkCell", for: indexPath)
        let linkTitle = Array(wikiLinks.keys)[indexPath.row]
        cell.textLabel?.text = linkTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let linkTitle = Array(wikiLinks.keys)[indexPath.row]
        if let urlString = wikiLinks[linkTitle], let url = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }
}


