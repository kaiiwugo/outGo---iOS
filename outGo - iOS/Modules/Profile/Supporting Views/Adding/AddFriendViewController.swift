//
//  AddFriendViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/12/21.
//

import UIKit

class AddFriendViewController: UIViewController {
    @IBOutlet weak var requestsButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userSearchTableView: UITableView!
    var requestedUsers = [String]()
    var userInfo = [UserProfile]()
    var userNames = [String]()
    var searchedUser = [String]()
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        setNavigation()
        loadUsers()
        checkRequests()
    }
    func setNavigation(){
        self.title = "Circle"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!]
        requestsButton.alpha = 0.25
        requestsButton.isEnabled = false
    }
    func setTable(){
        userSearchTableView.dataSource = self
        userSearchTableView.delegate = self
        self.userSearchTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        userSearchTableView.register(UsersTableViewCell.nib(), forCellReuseIdentifier: UsersTableViewCell.identifier)
        searchBar.delegate = self
    }
    func loadUsers(){
        FriendingHandler.shared.getAllUsers { result in
            self.userInfo = result
            result.forEach { user in
                self.userNames.append(user.userName)
            }
            self.userSearchTableView.reloadData()
        }
    }
    
    func checkRequests(){
        FriendingHandler.shared.allRequestCheck { result in
            if result.isEmpty == false {
                self.requestedUsers = result
                self.requestsButton.alpha = 1
                self.requestsButton.isEnabled = true
            }
        }
    }
    
    @IBAction func newFriendButton(_ sender: Any) {
        let friendRequestVC = FriendRequestViewController(nibName: "FriendRequestViewController", bundle: nil)
        friendRequestVC.requestedUsers = requestedUsers
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
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userSearchTableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.identifier, for: indexPath) as! UsersTableViewCell
        cell.selectionStyle = .none
        let image = UIImage(systemName: "face.smiling.fill")!
        if searching {
           let userName = searchedUser[indexPath.row]
            let user = userInfo.first { user in
                user.userName == userName
            }
            cell.configure(with: UserSearchModel(profilePicture: image, userName: userName, currentAction: "add", isFriend: user!.isFriend))
            return cell
        }
        else {
            
            return cell
        }
    }
    //Handles the table for the search bar
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(false)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

extension AddFriendViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searching = true
        if searchText == "" {
            searchedUser = []
        }
        else {
            searchedUser = userNames.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        }
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
