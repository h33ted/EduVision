import UIKit

class IntroViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let appNameLabel = UILabel()
    let introImageView = UIImageView()
    let tableView = UITableView(frame: .zero, style: .grouped)
    let lightBackgroundColor = UIColor(red: 239/255, green: 234/255, blue: 229/255, alpha: 1)
    let darkBackgroundColor = UIColor(red: 130/255, green: 108/255, blue: 127/255, alpha: 0.9)
    let lightAccentColor = UIColor.systemBrown
    let darkAccentColor = UIColor(red: 212/255, green: 178/255, blue: 216/255, alpha: 1.0)
    
    var backgroundColor: UIColor {
        traitCollection.userInterfaceStyle == .dark ? darkBackgroundColor : lightBackgroundColor
    }
    
    var accentColor: UIColor {
        traitCollection.userInterfaceStyle == .dark ? darkAccentColor : lightAccentColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustBackgroundColor()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        self.navigationController?.navigationBar.tintColor = accentColor
        setupView()
        setupConstraints()
    }
    
    func setupView() {
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = "Learniverse"
        navigationItem.backBarButtonItem = backButtonItem
        
        appNameLabel.text = "User's Learniverse"
        appNameLabel.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight(30))
        appNameLabel.textAlignment = .left
        introImageView.image = UIImage(named: "introImage")
        introImageView.contentMode = .scaleAspectFill
        introImageView.clipsToBounds = true
        introImageView.layer.cornerRadius = 10
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        tableView.layer.cornerCurve = .continuous
        view.addSubview(appNameLabel)
        view.addSubview(introImageView)
        view.addSubview(tableView)
    }
    
    private func adjustBackgroundColor() {
        view.backgroundColor = backgroundColor
        tableView.backgroundColor = backgroundColor
    }
    
    class CustomTableViewCell: UITableViewCell {
        var lightBackgroundColor: UIColor = UIColor(red: 229/255, green: 220/255, blue: 197/255, alpha: 0.7)
        var darkBackgroundColor: UIColor = UIColor(red: 104/255, green: 81/255, blue: 85/255, alpha: 0.7)
        
        var backgroundColorForCurrentStyle: UIColor {
            traitCollection.userInterfaceStyle == .dark ? darkBackgroundColor : lightBackgroundColor
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            let background = UIView()
            background.backgroundColor = backgroundColorForCurrentStyle
            background.layer.cornerRadius = 10
            
            self.backgroundView = background
            self.backgroundColor = .clear
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)

            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                self.backgroundView?.backgroundColor = backgroundColorForCurrentStyle
            }
        }
    }

    func setupConstraints() {
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        introImageView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        let appNameLabelTopConstraint = appNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        let appNameLabelLeadingConstraint = appNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        let appNameLabelTrailingConstraint = appNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)

        let introImageViewTopConstraint = introImageView.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 15)
        let introImageViewLeadingConstraint = introImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        let introImageViewTrailingConstraint = introImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        let introImageViewHeightConstraint = introImageView.heightAnchor.constraint(equalToConstant: 200)
        let introImageViewBottomConstraint = introImageView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -20)

        let tableViewLeadingConstraint = tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        let tableViewTrailingConstraint = tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        let tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)

        NSLayoutConstraint.activate([
            appNameLabelTopConstraint,
            appNameLabelLeadingConstraint,
            appNameLabelTrailingConstraint,
            introImageViewTopConstraint,
            introImageViewLeadingConstraint,
            introImageViewTrailingConstraint,
            introImageViewHeightConstraint,
            introImageViewBottomConstraint,
            tableViewLeadingConstraint,
            tableViewTrailingConstraint,
            tableViewBottomConstraint
        ])
    }

    let menuItems: [[String: Any]] = [
        ["name": "Summarize", "icon": UIImage(systemName: "character.book.closed")],
        ["name": "Quizzes", "icon": UIImage(systemName: "pencil.and.outline")],
        ["name": "Terms of Service", "icon": UIImage(systemName: "info.circle")],
        ["name": "Settings", "icon": UIImage(systemName: "gear")]
    ]
    
    // MARK: - TableView DataSource & Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuItems.count
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! CustomTableViewCell
          
          let menuItem = menuItems[indexPath.section]
          cell.textLabel?.text = menuItem["name"] as? String
          cell.imageView?.image = menuItem["icon"] as? UIImage
          cell.imageView?.tintColor = accentColor

          return cell
      }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = menuItems[indexPath.section]
        var vc: UIViewController?
        
        switch selectedItem["name"] as? String {
        case "Summarize":
            vc = wikiViewController()
        case "Quizzes":
            vc = quizcsvViewController()
        case "Settings":
            vc = settingsViewController()
        case "Terms of Service":
            vc = tosViewController()
        default:
            print("No view controller for selected menu item.")
        }
        
        if let viewController = vc {
            navigationController?.pushViewController(viewController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.imageView?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }) { _ in
                    UIView.animate(withDuration: 0.1) {
                        cell.imageView?.transform = CGAffineTransform.identity
                    }
                }
            }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 15
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)

            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                adjustBackgroundColor()
                self.navigationController?.navigationBar.tintColor = accentColor
                tableView.reloadData()
        }
    }
}

