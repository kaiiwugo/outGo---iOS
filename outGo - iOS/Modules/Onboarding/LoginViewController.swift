//
//  LoginViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/8/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "outGo"
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "RedFade"), for: .default)
    }
    @IBAction func loginButton(_ sender: Any) {
        let error = validateFields()
        if error != nil{
            showError(error!)
        }
        else{
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            //sign user in
            Auth.auth().signIn(withEmail: email, password: password) {
                (result, error) in
                //Check for signin error
                if error != nil{
                    self.showError("There was a problem logging in")
                }
                else {
                    self.signIn()
                }
            }
        }
    }
    func signIn(){
        let db = Firestore.firestore()
        let authID = Auth.auth().currentUser
        let userID = String(authID!.uid)
        let userDocument = db.collection("Users").document(userID).collection("properties").document("properties")
        
        userDocument.getDocument { (document, error) in
            if error == nil && document != nil {
                let userName = document?.get("userName") as! String
                UserDefaults.standard.set(userName, forKey: "currentUser")
                self.logIn()
            }
            else {
                self.showError("Error")
                return
            }
        }
    }
        
    func validateFields() -> String? {
        //Checks that all fields are filled in
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "please fill in all fields"
        }
        return nil
    }
    
    func showError(_ message:String){
        errorMessageLabel.text = message
        errorMessageLabel.alpha = 1
    }
    
    func logIn(){
        let vc = CustomTabBarViewController()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }
}
