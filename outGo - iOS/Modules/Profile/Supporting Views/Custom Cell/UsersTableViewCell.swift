//
//  UsersTableViewCell.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/12/21.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var userName: UILabel!
    static let identifier = "UsersTableViewCell"
    @IBOutlet var userActionButton: UIButton!
    @IBOutlet var rejectButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        userActionButton.alpha = 0
        rejectButton.alpha = 0
        userActionButton.clipsToBounds = true
        userActionButton.layer.cornerRadius = 5
        userActionButton.layer.borderWidth = 2
        userActionButton.layer.borderColor = UIColor.separator.cgColor
    }
    
    public func configure(with model: UserSearchModel){
        self.profilePicture.image = model.profilePicture
        self.userName.text = model.userName
        
        switch model.isFriend {
        case true:
            userActionButton.alpha = 0
            break
        case false:
            userActionButton.alpha = 1
            break
        }
        switch model.currentAction {
        case "add":
            userActionButton.setTitle("add", for: .normal)
            break
        case "accecpt":
            userActionButton.setTitle("accecpt", for: .normal)
            userActionButton.alpha = 1
            rejectButton.alpha = 1
            break
        case "circle":
            userActionButton.setTitle("remove", for: .normal)
            userActionButton.alpha = 1
            break
        default:
            break
        }
        
    }
    
    @IBAction func userActionButton(_ sender: Any) {
        if userActionButton.titleLabel?.text == "remove" {
            FriendingHandler.shared.removeFriend(friendName: userName.text!)
            userActionButton.isEnabled = false
            userActionButton.setTitle("", for: .normal)
            userActionButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        }
        else {
            FriendingHandler.shared.addFriend(friendName: userName.text!)
            userActionButton.isEnabled = false
            userActionButton.setTitle("", for: .normal)
            userActionButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        }
        rejectButton.alpha = 0
    }
    @IBAction func rejectButton(_ sender: Any) {
        FriendingHandler.shared.rejectUser(userName: userName.text!)
        contentView.isUserInteractionEnabled = false
        contentView.alpha = 0.25
    }
    
    
    static func nib() -> UINib {
        return UINib(nibName: "UsersTableViewCell", bundle: nil)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
            let margins = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
    }
    
}
