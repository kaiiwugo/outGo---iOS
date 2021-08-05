//
//  AffiliationsViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/29/21.
//

import UIKit
import FirebaseFirestore

class AffiliationsViewController: UIViewController {
    let db = Firestore.firestore()
    let currentUser = UserDefaults.standard.string(forKey: "currentUser")
    let userGroup = UserDefaults.standard.string(forKey: "groupName")
    @IBOutlet weak var templeButton: UIButton!
    @IBOutlet weak var templeButtonView: UIView!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addInfoView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var badgeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        setup()
        groupCheck()
    }
    func setup(){
        self.title = "My Groups"
        templeButtonView.alpha = 0.25
        addInfoView.alpha = 0
        verifyButton.layer.cornerRadius = 5
        verifyButton.backgroundColor = colors.getColor(color: .primary)
        templeButtonView.layer.cornerRadius = templeButtonView.frame.size.width/2
        templeButtonView.clipsToBounds = true
        templeButtonView.layer.borderColor = UIColor.separator.cgColor
        templeButtonView.layer.borderWidth = 1
    }
    
    func groupCheck(){
        if userGroup != ""{
            templeButtonView.alpha = 1
            addLabel.alpha = 0
            templeButtonView.isUserInteractionEnabled = false
            badgeImage.alpha = 1
            templeButtonView.layer.borderWidth = 0
        }
    }
    
    @IBAction func templeButton(_ sender: Any) {
        addInfoView.alpha = 1
    }
    

    @IBAction func verifyButton(_ sender: Any) {
        if verifyEmail() == true {
            templeButtonView.alpha = 1
            templeButtonView.isUserInteractionEnabled = false
            addLabel.alpha = 0
            addInfoView.alpha = 0
            showMessage(message: "Group Added")
            addGroup()
        }
        
    }
    
    func addGroup(){
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        db.collection("Users").document(currentUser!).setData(["group": ["groupName": "Temple", "groupID": email]], merge: true)
        UserDefaults.standard.set("Temple", forKey: "groupName")
        UserDefaults.standard.set(email, forKey: "groupID")
        emailTextField.text = ""
    }
    
    func verifyEmail() -> Bool{
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let check = email.suffix(11)
        if check == "@temple.edu" {
            return true
        }
        else {
            showMessage(message: "Failed to authenticate")
            return false
        }
    }
    
    func showMessage(message: String){
        errorLabel.text = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.errorLabel.text = ""
        }
    }
    
}
