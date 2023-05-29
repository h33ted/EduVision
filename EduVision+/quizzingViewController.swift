//
//  quizzingViewController.swift
//  EduVision+
//
//  Created by George-Cristian Cotea on 12/05/2023.
//  Copyright © 2023 george. All rights reserved.
//

import UIKit

class quizzingViewController: UIViewController {
    private var infoLabel: UILabel!
    private var iconImageView: UIImageView!
    private var titleLabel = UILabel()  // The title label
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        adjustBackgroundColor()
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
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        infoLabel.text = "You came here too soon!"

        iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(systemName: "exclamationmark.triangle")
        iconImageView.tintColor = .systemGray

        view.addSubview(infoLabel)
        view.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),

            infoLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
