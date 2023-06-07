import UIKit
import VisionKit
import Vision

struct Quiz: Codable {
    struct Question: Codable {
        let question: String
        let options: [String]
        let answer: Int
    }
    let questions: [Question]
}

class quizcsvViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    
    let lightBackgroundColor = UIColor(red: 239/255, green: 234/255, blue: 229/255, alpha: 1)
    let darkBackgroundColor = UIColor(red: 130/255, green: 108/255, blue: 127/255, alpha: 0.9)
    let lightAccentColor = UIColor.systemBrown
    let darkAccentColor = UIColor(red: 212/255, green: 178/255, blue: 216/255, alpha: 1.0)
    
    var quiz: Quiz?
    var ocrText = ""
    let serverURL = URL(string: "http://185.229.227.172:1331/questions")!
    var startOCRButton : UIButton!
    var questionViews: [UIView] = []
    var radioButtons : [[UIButton]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Start OCR button
        startOCRButton = UIButton(type: .system)
        startOCRButton.setTitle("Generate Quizzes", for: .normal)
        startOCRButton.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight(rawValue: 20))
        //startOCRButton.setImage(UIImage(systemName: "camera.badge.ellipsis"), for: .normal)
        //startOCRButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        startOCRButton.layer.cornerRadius = 10
        startOCRButton.layer.borderWidth = 0
        startOCRButton.layer.borderColor = UIColor(red: 239/255, green: 234/255, blue: 229/255, alpha: 1).cgColor
        startOCRButton.setTitleColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3), for: .normal)
        startOCRButton.backgroundColor = UIColor(red: 210/255, green: 180/255, blue: 140/255, alpha: 1.0)
        startOCRButton.setTitleColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4), for: .highlighted)
        startOCRButton.translatesAutoresizingMaskIntoConstraints = false
        startOCRButton.addTarget(self, action: #selector(startOCR), for: .touchUpInside)

        view.addSubview(startOCRButton)
        
        // Constraints for the Start OCR button
        NSLayoutConstraint.activate([
            startOCRButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startOCRButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        // Apply color theme based on user's device settings
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .dark {
            view.backgroundColor = darkBackgroundColor
            startOCRButton.setTitleColor(darkAccentColor, for: .normal)
        } else {
            view.backgroundColor = lightBackgroundColor
            startOCRButton.setTitleColor(lightAccentColor, for: .normal)
        }
    }
     
     // Change color when the user changes the device theme
     override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
         super.traitCollectionDidChange(previousTraitCollection)

         let userInterfaceStyle = traitCollection.userInterfaceStyle
         if userInterfaceStyle == .dark {
             view.backgroundColor = darkBackgroundColor
             startOCRButton.setTitleColor(darkAccentColor, for: .normal)
         } else {
             view.backgroundColor = lightBackgroundColor
             startOCRButton.setTitleColor(lightAccentColor, for: .normal)
         }
     }

     @objc func startOCR(_ sender: Any) {
         let documentCameraViewController = VNDocumentCameraViewController()
         documentCameraViewController.delegate = self
         present(documentCameraViewController, animated: true)
     }
    
    func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            if let error = error {
                print("OCR error: \(error)")
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let recognizedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }
            DispatchQueue.main.async {
                self?.ocrText = recognizedStrings.joined(separator: "\n")
                self?.sendTextToServer()
            }
        }
        let requests = [request]
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform(requests)
        }
    }
    
        func sendTextToServer() {
            var request = URLRequest(url: serverURL)
            request.httpMethod = "POST"
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var data = Data()
            //let formData = "text=\(ocrText)"
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"text\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(ocrText)\r\n".data(using: .utf8)!)
            data.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = data

            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    print("Error sending request: \(error)")
                    return
                }
                guard let data = data else {
                    print("No data received.")
                    return
                }
                print(String(data: data, encoding: .utf8) ?? "Not a valid UTF-8 sequence")  // Add this line
                do {
                    let questions = try JSONDecoder().decode([Quiz.Question].self, from: data)
                    DispatchQueue.main.async {
                        let quiz = Quiz(questions: questions)
                        self?.presentQuiz(quiz)
                    }
                } catch {
                    print("Error decoding response data: \(error)")
                }
            }
            task.resume()
        }

    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        let originalImage = scan.imageOfPage(at: 0)
        processImage(originalImage)
        
        controller.dismiss(animated: true)
    }
    func presentQuiz(_ quiz: Quiz) {
        // Save the quiz
        self.quiz = quiz
        
        // Create a UIScrollView and add it to the view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: startOCRButton.topAnchor),
        ])
        
        // Create a vertical UIStackView and add it to the UIScrollView
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        // Create a UIView for each question, add them to the UIStackView
        for question in quiz.questions {
            let questionView = UIView()
            stackView.addArrangedSubview(questionView)
            
            let questionLabel = UILabel()
            questionLabel.text = question.question
            questionLabel.font = UIFont.boldSystemFont(ofSize: 17)
            questionLabel.translatesAutoresizingMaskIntoConstraints = false
            questionView.addSubview(questionLabel)
            NSLayoutConstraint.activate([
                questionLabel.topAnchor.constraint(equalTo: questionView.topAnchor),
                questionLabel.leadingAnchor.constraint(equalTo: questionView.leadingAnchor, constant: 20),
                questionLabel.trailingAnchor.constraint(equalTo: questionView.trailingAnchor, constant: -20),
            ])
            
            var previousButton: UIButton?
            var buttons: [UIButton] = []
            for (index, option) in question.options.enumerated() {
                let button = UIButton(type: .system)
                button.setTitle(option, for: .normal)
                button.addTarget(self, action: #selector(answerSelected), for: .touchUpInside)
                button.tag = index
                button.translatesAutoresizingMaskIntoConstraints = false
                questionView.addSubview(button)
                
                var constraints = [
                    button.topAnchor.constraint(equalTo: (previousButton?.bottomAnchor ?? questionLabel.bottomAnchor), constant: 20),
                    button.leadingAnchor.constraint(equalTo: questionView.leadingAnchor, constant: 20),
                    button.trailingAnchor.constraint(equalTo: questionView.trailingAnchor, constant: -20),
                ]
                
                if index == question.options.count - 1 {
                    constraints.append(button.bottomAnchor.constraint(equalTo: questionView.bottomAnchor))
                }
                
                NSLayoutConstraint.activate(constraints)
                buttons.append(button)
                previousButton = button
            }
            
            radioButtons.append(buttons)
        }
    }

    
    @objc func answerSelected(_ sender: UIButton) {
            guard let questionIndex = radioButtons.firstIndex(where: { $0.contains(sender) }),
                let question = quiz?.questions[questionIndex] else { return }
            if sender.tag + 1 == question.answer {
                // Correct answer
                sender.backgroundColor = UIColor.green
            } else {
                // Wrong answer
                sender.backgroundColor = UIColor.red
                radioButtons[questionIndex][question.answer - 1].backgroundColor = UIColor.green
            }
            // Disable all buttons for this question
            radioButtons[questionIndex].forEach { $0.isEnabled = false }
        }
    
    func presentOptions(_ question: Quiz.Question) {
        let alertController = UIAlertController(title: question.question, message: nil, preferredStyle: .actionSheet)
        for (index, option) in question.options.enumerated() {
            let action = UIAlertAction(title: option, style: .default) { [weak self] _ in
                self?.checkAnswer(index + 1 == question.answer, for: question)
            }
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func checkAnswer(_ isCorrect: Bool, for question: Quiz.Question) {
        let title = isCorrect ? "Correct!" : "Wrong!"
        let message = isCorrect ? nil : "The correct answer was: \(question.options[question.answer - 1])"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
    
extension quizcsvViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quiz?.questions.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath)
        cell.textLabel?.text = quiz?.questions[indexPath.row].question
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let question = quiz?.questions[indexPath.row] else { return }
        presentOptions(question)
    }
}
