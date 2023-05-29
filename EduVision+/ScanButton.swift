
//  ScanButton.swift
//  EduVision+
//  Created by George-Cristian Cotea on 12/05/2023.
//  Copyright © 2023 george. All rights reserved.



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
        configuration.background.strokeWidth = 0
        configuration.background.strokeColor = UIColor(red: 239/255, green: 234/255, blue: 229/255, alpha: 1)
        configuration.baseForegroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4) : UIColor (red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        }
        configuration.baseBackgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(red: 168/255, green: 143/255, blue: 172/255, alpha: 0.7) : UIColor(red: 210/255, green: 180/255, blue: 140/255, alpha: 1.0) }
        self.configuration = configuration
    }
}
