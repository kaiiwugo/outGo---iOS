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
        let vc1 = UINavigationController(rootViewController: MapViewController())
        let vc2 = UINavigationController(rootViewController: ProfileViewController())
        UITabBar.appearance().barTintColor = UIColor.systemBackground
        tabBar.isTranslucent = false
        viewControllers = [vc1, vc2]
        // Do any additional setup after loading the view.
    }

}
