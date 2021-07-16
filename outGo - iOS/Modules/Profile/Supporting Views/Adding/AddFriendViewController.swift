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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        setNavigation()
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


}

extension AddFriendViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userSearchTableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.identifier, for: indexPath) as! UsersTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}
