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
        setImage(UIImage(systemName: "camera.badge.ellipsis"), for: .normal)
        tintColor = .label
        backgroundColor = .systemBackground
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemYellow.cgColor
        imageView?.contentMode = .scaleAspectFit
    }
}
