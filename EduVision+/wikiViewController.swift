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
    private var textViewActivityIndicator = UIActivityIndicatorView(style: .large)
    private var tableViewActivityIndicator = UIActivityIndicatorView(style: .large)
    private var placeholderLabel = UILabel()


    override func viewDidLoad() {
            super.viewDidLoad()
        
            adjustBackgroundColor()
            configure()
            configureOCR()
            configureTableView()
        }

        
    private func adjustBackgroundColor() {
        view.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(red: 130/255, green: 108/255, blue: 127/255, alpha: 1) : UIColor(red: 239/255, green: 234/255, blue: 229/255, alpha: 1)
        }

        summaryTextView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(red: 168/255, green: 143/255, blue: 172/255, alpha: 1) : UIColor(red: 245/255, green: 222/255, blue: 179/255, alpha: 1.0)
        }

        wikiLinksTableView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(red: 168/255, green: 143/255, blue: 172/255, alpha: 1) : UIColor(red: 245/255, green: 222/255, blue: 179/255, alpha: 1.0)
        }
    }

    
    private func configure() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
                titleLabel.text = "Summarize"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight(30))
                titleLabel.textAlignment = .left
                view.addSubview(titleLabel)
        view.addSubview(summaryTextView)
        view.addSubview(wikiLinksTableView)
        view.addSubview(scanButton)

        summaryTextView.translatesAutoresizingMaskIntoConstraints = false
        wikiLinksTableView.translatesAutoresizingMaskIntoConstraints = false
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        summaryTextView.addSubview(textViewActivityIndicator)
        wikiLinksTableView.addSubview(tableViewActivityIndicator)
        textViewActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        tableViewActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        summaryTextView.isEditable = false
        let padding: CGFloat = 16
        let verticalAdjustment: CGFloat = 6 // This is the adjustment value

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: verticalAdjustment),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),

            summaryTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding + verticalAdjustment),
            summaryTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            summaryTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),

            wikiLinksTableView.topAnchor.constraint(equalTo: summaryTextView.bottomAnchor, constant: padding + verticalAdjustment),
            wikiLinksTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            wikiLinksTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            wikiLinksTableView.heightAnchor.constraint(equalToConstant: 200),

            scanButton.topAnchor.constraint(equalTo: wikiLinksTableView.bottomAnchor, constant: padding + verticalAdjustment),
            scanButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            scanButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            scanButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding - verticalAdjustment),

            textViewActivityIndicator.centerXAnchor.constraint(equalTo: summaryTextView.centerXAnchor),
            textViewActivityIndicator.centerYAnchor.constraint(equalTo: summaryTextView.centerYAnchor),
                    
            tableViewActivityIndicator.centerXAnchor.constraint(equalTo: wikiLinksTableView.centerXAnchor),
            tableViewActivityIndicator.centerYAnchor.constraint(equalTo: wikiLinksTableView.centerYAnchor),
        ])


        //summaryTextView.backgroundColor = UIColor(red: 245/255, green: 222/255, blue: 179/255, alpha: 1.0)
        summaryTextView.textColor = .black
        summaryTextView.font = UIFont.systemFont(ofSize: 18)
        summaryTextView.layer.cornerRadius = 16
        summaryTextView.textContainerInset = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        summaryTextView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
       
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textAlignment = .center
        placeholderLabel.text = "No summary yet.\nScan a document to get started."
        placeholderLabel.font = UIFont.boldSystemFont(ofSize: 22) // make the font bold and increase size here
        placeholderLabel.textColor = UIColor.black.withAlphaComponent(0.3) // make text slightly transparent here
        placeholderLabel.sizeToFit()

        summaryTextView.addSubview(placeholderLabel)
        // You need to adjust the label's frame to fit in the center of your text view.
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.centerXAnchor.constraint(equalTo: summaryTextView.centerXAnchor).isActive = true
        placeholderLabel.centerYAnchor.constraint(equalTo: summaryTextView.centerYAnchor).isActive = true
        placeholderLabel.isHidden = !summaryTextView.text.isEmpty



        wikiLinksTableView.layer.cornerRadius = 16
        wikiLinksTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        wikiLinksTableView.separatorColor = UIColor(red: 150/255, green: 111/255, blue: 51/255, alpha: 1.0)
        
        scanButton.addTarget(self, action: #selector(scanDocument), for: .touchUpInside)
    }
    
    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !summaryTextView.text.isEmpty
    }

    private func configureTableView() {
        wikiLinksTableView.delegate = self
        wikiLinksTableView.dataSource = self
        wikiLinksTableView.register(UITableViewCell.self, forCellReuseIdentifier: "wikiLinkCell")
        //wikiLinksTableView.backgroundColor = UIColor(red: 245/255, green: 222/255, blue: 179/255, alpha: 1.0)
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

            DispatchQueue.main.async {
                self.textViewActivityIndicator.startAnimating()
            }

            let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                guard let data = data, error == nil else { return }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self?.summaryTextView.text = jsonResponse["response"] as? String ?? ""
                            self?.scanButton.isEnabled = true
                            self?.updatePlaceholderVisibility() // update visibility of the placeholder
                            self?.summaryTextView.text = jsonResponse["response"] as? String ?? ""
                            self?.scanButton.isEnabled = true
                            self?.textViewActivityIndicator.stopAnimating()
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
            
            DispatchQueue.main.async {
                self.tableViewActivityIndicator.startAnimating()
            }
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                guard let data = data, error == nil else { return }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                        DispatchQueue.main.async {
                            self?.wikiLinks = jsonResponse
                            self?.wikiLinksTableView.reloadData()
                            self?.tableViewActivityIndicator.stopAnimating()
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



