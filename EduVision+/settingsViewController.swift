//
//  settingsViewController.swift
//  EduVision+
//
//  Created by George-Cristian Cotea on 07/06/2023.
//  Copyright © 2023 george. All rights reserved.
//

import Foundation
import UIKit

class settingsViewController: UIViewController {
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
            view.backgroundColor = UIColor(red: 130/255, green: 108/255, blue: 127/255, alpha: 1)
            iconImageView.tintColor = UIColor(red: 168/255, green: 143/255, blue: 172/255, alpha: 0.7)
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
        iconImageView.tintColor = .black.withAlphaComponent(0.3)

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
