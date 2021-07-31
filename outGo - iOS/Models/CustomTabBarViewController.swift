//
//  CustomTabBarViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/24/21.
//

import UIKit

class CustomTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        //Customizes the tab and navigation bar of each
        let map = UINavigationController(rootViewController: MapViewController())
        map.title = "map"
        map.tabBarItem.image = UIImage(systemName: "globe")
        map.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 10)!], for: .normal)
        //profile
        let profile = UINavigationController(rootViewController: ProfileViewController())
        profile.title = "Circle"
        profile.tabBarItem.image = UIImage(systemName: "person.3")
        profile.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 10)!], for: .normal)
        
        UITabBar.appearance().barTintColor = UIColor.black
        tabBar.isTranslucent = false
        tabBar.tintColor = .white
        viewControllers = [map, profile]
        // Do any additional setup after loading the view.
    }

}
