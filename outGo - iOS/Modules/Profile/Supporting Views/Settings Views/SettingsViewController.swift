//
//  SettingsViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/12/21.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pullDownBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup(){
        pullDownBar.layer.cornerRadius = 3
        contentView.layer.cornerRadius = 10
    }
    
    @IBAction func mySettingsButton(_ sender: Any) {
    }
    
    @IBAction func suggestNewFeatureButton(_ sender: Any) {
    }
    
    @IBAction func reportBugButton(_ sender: Any) {
    }
    
    @IBAction func termsOfServiceButton(_ sender: Any) {
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        let vc = UINavigationController(rootViewController: InitialViewController())
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }
}
