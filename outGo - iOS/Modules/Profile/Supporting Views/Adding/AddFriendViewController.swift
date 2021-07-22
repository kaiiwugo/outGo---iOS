//
//  AddFriendViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/12/21.
//

import UIKit

class AddFriendViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var newFriendImage: UIButton!
    @IBOutlet weak var userSearchTableView: UITableView!
    var userInfo = [UserProfile]()
    var userNames = [String]()
    var searchedUser = [String]()
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        setNavigation()
        loadUsers()
    }
    func setNavigation(){
        self.title = "Add"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!]
    }
    func setTable(){
        userSearchTableView.dataSource = self
        userSearchTableView.delegate = self
        self.userSearchTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        userSearchTableView.register(UsersTableViewCell.nib(), forCellReuseIdentifier: UsersTableViewCell.identifier)
    }
    func loadUsers(){
        print("calling")
        FriendingHandler.shared.getAllUsers { result in
            print("RES: \(result)")
            self.userInfo = result
            result.forEach { user in
                self.userNames.append(user.userName)
            }
            self.userSearchTableView.reloadData()
            
        }
    }
    
    @IBAction func newFriendButton(_ sender: Any) {
        let friendRequestVC = FriendRequestViewController(nibName: "FriendRequestViewController", bundle: nil)
        show(friendRequestVC, sender: self)
    }
    
    func closeKeyboards(){
        self.view.endEditing(false)
    }
}

extension AddFriendViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return searchedUser.count
        }
        else{
            //or default number
            return userNames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userSearchTableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.identifier, for: indexPath) as! UsersTableViewCell
        var userName = ""
        let image = UIImage(systemName: "face.smiling.fill")!
        if searching {
            userName = searchedUser[indexPath.row]
        }
        else {
            userName = userNames[indexPath.row]
        }
        cell.configure(with: UserModel(profilePicture: image, userName: userName, currentAction: "add"))
        return cell
    }
    //Handles the table for the search bar
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userName = searchedUser[indexPath.row]
        //performSegue(withIdentifier: "profileSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

extension AddFriendViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedUser = userNames.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        userSearchTableView.alpha = 1
        userSearchTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = nil
        userSearchTableView.alpha = 0
        closeKeyboards()
        userSearchTableView.reloadData()
    }
    
}
