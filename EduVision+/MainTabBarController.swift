//
//  MainTabBarController.swift
//  EduVision+
//
//  Created by George-Cristian Cotea on 12/05/2023.
//  Copyright © 2023 george. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        adjustTabBarColorScheme()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        adjustTabBarColorScheme()
    }

    func setupViewControllers() {
        let wikiVC = wikiViewController()
        let quizzingVC = quizzingViewController()
        let quizCSVVC = quizcsvViewController()

        wikiVC.tabBarItem = UITabBarItem(title: "Wiki", image: UIImage(systemName: "character.book.closed"), tag: 0)
        quizzingVC.tabBarItem = UITabBarItem(title: "Multiple Choice", image: UIImage(systemName: "pencil.and.outline"), tag: 1)
        quizCSVVC.tabBarItem = UITabBarItem(title: "Flashcards", image: UIImage(systemName: "rectangle.stack"), tag: 2)

        let navigationController1 = UINavigationController(rootViewController: wikiVC)
        let navigationController2 = UINavigationController(rootViewController: quizzingVC)
        let navigationController3 = UINavigationController(rootViewController: quizCSVVC)

        viewControllers = [navigationController1, navigationController2, navigationController3]
    }
    
    func adjustTabBarColorScheme() {
        if self.traitCollection.userInterfaceStyle == .dark {
            // Use lighter colors for dark mode
            tabBar.tintColor = UIColor(red: 212/255, green: 178/255, blue: 216/255, alpha: 1.0)
            tabBar.unselectedItemTintColor = UIColor.lightGray
        } else {
            // Use darker colors for light mode
            tabBar.tintColor = UIColor.systemBrown
            tabBar.unselectedItemTintColor = UIColor.label
        }
    }
}
