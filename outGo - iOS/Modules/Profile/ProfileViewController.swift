//
//  ProfileViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/24/21.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var badgeImage: UIImageView!
    @IBOutlet weak var myCircleButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigation()
        setButtons()
        setProfile()
    }
    
    func setNavigation(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "RedFade"), for: .default)
        self.title = "outGo"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "escape"), style: .plain, target: self, action: #selector(logoutButton))
        self.navigationItem.leftBarButtonItem?.tintColor = .label
    }
    
    func setButtons(){
        myCircleButton.tintColor = .label
        settingsButton.tintColor = .label
        addButton.tintColor = .label
        myCircleButton.layer.cornerRadius = myCircleButton.frame.width/2
        myCircleButton.clipsToBounds = true
        settingsButton.layer.cornerRadius = settingsButton.frame.width/2
        settingsButton.clipsToBounds = true
        addButton.layer.cornerRadius = addButton.frame.width/2
        addButton.clipsToBounds = true
    }
    
    func setProfile(){
        userNameLabel.text = UserDefaults.standard.string(forKey: "currentUser")
    }

    @IBAction func myCircleButton(_ sender: Any) {
        let circleVC = CircleViewController(nibName: "CircleViewController", bundle: nil)
        show(circleVC, sender: self)
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        FriendingHandler.shared.test()
    }
    
    @IBAction func addFriendButton(_ sender: Any) {
        let addVC = AddFriendViewController(nibName: "AddFriendViewController", bundle: nil)
        show(addVC, sender: self)
    }
    
    @objc func logoutButton(sender: UIBarButtonItem) {
        
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        let vc = UINavigationController(rootViewController: InitialViewController())
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }

    
    @IBAction func adminPowers(_ sender: Any) {
        AdminAddPresets.shared.addEvent()
    }
    

}
