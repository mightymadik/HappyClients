//  TabBarViewController.swift
//  HappyClients
//
//  Created by MacBook on 12.04.2023.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var profilePhotoRef: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpControllers()
        
    }
    
    private func setUpControllers(){
        
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else{
            return
        }
        let home = HomeViewController()
        home.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24.0, weight: .medium)]
        home.navigationItem.largeTitleDisplayMode = .never;      home.navigationItem.title = "Billboards List - \(currentUserEmail)"
        
        let profile = ProfileViewController(currentEmail: currentUserEmail)
        profile.title = "Profile"
        profile.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: profile)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)
        
        setViewControllers([nav1, nav2], animated: true)
        
    }
}
