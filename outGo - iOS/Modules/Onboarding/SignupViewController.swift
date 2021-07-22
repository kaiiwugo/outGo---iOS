//
//  SignupViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/7/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignupViewController: UIViewController {
    enum Collection: String {
        case properties = "properties"
        case circle = "circle"
    }
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "outGo"
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "RedFade"), for: .default)
    }

    @IBAction func loginButton(_ sender: Any) {
        let error = validateFields()
        if error != nil {
            showError(error!)
        }
        else {
            let userName = userNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            //Create the User
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                //Check for errors
                if err != nil {
                    //if you want to see the exact reason for the error
                    //let errormsg = err!.localizedDescription
                    self.showError("There was a problem creating your account")
                }
                else {
                    self.db.collection("Users").document(result!.user.uid).collection(Collection.properties.rawValue).document(Collection.properties.rawValue).setData(["userName":userName, "email":email, "UID":result!.user.uid]) { (error) in
                        //if theres an error message, show it
                        if error != nil{
                            self.showError("Error saving user data")
                        }
                    }
                }
            }
            UserDefaults.standard.set(userName, forKey: "currentUser")
            //Retrieve: UserDefaults.standard.string(forKey: "currentUser")
            logIn()
        }
    }
    
    func validateFields() -> String? {
        //Checks that all fields are filled in
        if
        userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "please fill in all fields"
        }
        //checks if password is secure
        let cleanPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if isPasswordValid(cleanPassword) == false {
            return "Password length must be at least 6 and it must have at least 1 character"
        }
        return nil
    }
    
    func showError(_ message:String){
        errorMessageLabel.text = message
        errorMessageLabel.alpha = 1
    }
    func isPasswordValid(_ password : String) -> Bool {
        //password security requirements
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])[A-Za-z\\d$@$#!%*?&]{6,}")
        return passwordTest.evaluate(with: password)
    }
    
    func logIn(){
        let vc = CustomTabBarViewController()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }
    
}
