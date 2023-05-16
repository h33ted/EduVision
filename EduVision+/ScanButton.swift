//
//  ScanButton.swift
//  EduScan+
//
//

import UIKit

class ScanButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Creating a button that uses the camera.badge.ellipsis SfSymbol
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.filled()
        configuration.title = " "
        configuration.image = UIImage(systemName: "camera.badge.ellipsis")
        configuration.imagePadding = 8
        configuration.background.cornerRadius = 10
        configuration.background.strokeWidth = 2
        configuration.background.strokeColor = UIColor.systemYellow
        configuration.baseForegroundColor = .label
        configuration.baseBackgroundColor = .systemBackground
        self.configuration = configuration
    }
}
