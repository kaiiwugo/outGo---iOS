//
//  InitialViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/16/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class InitialViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "outGo"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Medium", size: 25)!]
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                navigationItem.backBarButtonItem = backBarButtonItem
        loginButton.alpha = 0
        signupButton.alpha = 0
        logoImage.alpha = 0
        addUserListener()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Medium", size: 25)!, .foregroundColor: UIColor.white]
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.separator.cgColor
        loginButton.layer.cornerRadius = 5
        signupButton.layer.cornerRadius = 5
        signupButton.clipsToBounds = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "RedFade"), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        show(loginVC, sender: self)
    }
    
    @IBAction func signupButton(_ sender: Any) {
        let signupVC = SignupViewController(nibName: "SignupViewController", bundle: nil)
        show(signupVC, sender: self)
    }
    
    func addUserListener() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                //not logged in
                self.loginButton.alpha = 1
                self.signupButton.alpha = 1
                self.logoImage.alpha = 1
                
            } else {
                // we are Logged In to Firebase
                let vc = CustomTabBarViewController()
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
            }
        }
    }
}
