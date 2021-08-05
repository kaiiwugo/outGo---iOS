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
        let reportBugVC = ReportBugViewController(nibName: "ReportBugViewController", bundle: nil)
        reportBugVC.sender = "suggestion"
        reportBugVC.modalPresentationStyle = .fullScreen
        reportBugVC.modalTransitionStyle = .crossDissolve
        present(reportBugVC, animated: true, completion: nil)
    }
    
    @IBAction func reportBugButton(_ sender: Any) {
        let reportBugVC = ReportBugViewController(nibName: "ReportBugViewController", bundle: nil)
        reportBugVC.sender = "bug"
        reportBugVC.modalPresentationStyle = .fullScreen
        reportBugVC.modalTransitionStyle = .crossDissolve
        present(reportBugVC, animated: true, completion: nil)
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
