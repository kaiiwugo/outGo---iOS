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
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            self.friend = []
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
        cell.selectionStyle = .none
        let userName = friend[indexPath.row]
        let image = UIImage(systemName: "face.smiling.fill")!
        cell.configure(with: UserSearchModel(profilePicture: image, userName: userName, currentAction: "circle", isFriend: true))
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(false)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    
    
    
}
