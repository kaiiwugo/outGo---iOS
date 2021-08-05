//
//  ReportBugViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 8/2/21.
//

import UIKit
import FirebaseFirestore

class ReportBugViewController: UIViewController {
    enum UserMessage: String {
        case report = "Please describe the problem you expirenced"
        case suggest = "Tell us what'd you'd like to see next"
    }
    let db = Firestore.firestore()
    let currentUser = UserDefaults.standard.string(forKey: "currentUser")
    @IBOutlet weak var userMessagelabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var thanksLabel: UILabel!
    var sender = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        setup()
    }

    func setup(){
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.separator.cgColor
        if sender == "bug" {
            userMessagelabel.text = UserMessage.report.rawValue
        }
        else {
            userMessagelabel.text = UserMessage.suggest.rawValue
        }
    }
    
    func success(){
        descriptionTextView.alpha = 0
        userMessagelabel.alpha = 0
        thanksLabel.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func submitButton(_ sender: Any) {
        let description = descriptionTextView.text
        if self.sender == "bug" {
            db.collection("Reported Bugs").document().setData(["Description": description, "user": currentUser])
        }
        else {
            db.collection("User Suggestions").document().setData(["Description": description, "user": currentUser])
        }
        success()
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
