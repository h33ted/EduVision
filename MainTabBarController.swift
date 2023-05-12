import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor.systemBrown
        tabBar.unselectedItemTintColor = UIColor.label
        setupViewControllers()
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
    }

