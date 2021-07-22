//
//  CircleViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/12/21.
//

import UIKit

class CircleViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var friendsTableView: UITableView!
    var friend = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        setNavigation()
        loadFriends()
    }
    
    func setNavigation(){
        self.title = "Circle"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!]
    }
    
    func setTable(){
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        self.friendsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        friendsTableView.register(UsersTableViewCell.nib(), forCellReuseIdentifier: UsersTableViewCell.identifier)
    }
    
    func loadFriends(){
        DispatchQueue.main.async {
            FirestoreService.shared.getFriends { result in
                result.forEach { user in
                    self.friend.append(user.userName)
                }
                self.friendsTableView.reloadData()
            }
        }
    }


}

extension CircleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.friend.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.identifier, for: indexPath) as! UsersTableViewCell
        let userName = friend[indexPath.row] ?? "willy"
        let image = UIImage(systemName: "face.smiling.fill")!
        cell.configure(with: UserModel(profilePicture: image, userName: userName, currentAction: "circle"))
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    
    
    
}
