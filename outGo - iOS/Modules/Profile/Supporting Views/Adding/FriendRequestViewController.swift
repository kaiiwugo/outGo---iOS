//
//  FriendRequestViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/15/21.
//

import UIKit

class FriendRequestViewController: UIViewController {
    @IBOutlet weak var friendRequestTableView: UITableView!
    var requestedUsers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        setNavigation()
    }
    func setNavigation(){
        self.title = "Circle"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!]
    }
    func setTable(){
        friendRequestTableView.dataSource = self
        friendRequestTableView.delegate = self
        self.friendRequestTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        friendRequestTableView.register(UsersTableViewCell.nib(), forCellReuseIdentifier: UsersTableViewCell.identifier)
    }
}

extension FriendRequestViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requestedUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendRequestTableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.identifier, for: indexPath) as! UsersTableViewCell
        cell.selectionStyle = .none
        let userName = requestedUsers[indexPath.row]
        let image = UIImage(systemName: "face.smiling.fill")!
        cell.configure(with: UserSearchModel(profilePicture: image, userName: userName, currentAction: "accecpt", isFriend: false))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
}
