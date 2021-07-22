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
    @IBOutlet var accecptButton: UIButton!
    @IBOutlet var rejectButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        accecptButton.alpha = 0
        rejectButton.alpha = 0
        accecptButton.clipsToBounds = true
        accecptButton.layer.cornerRadius = 5

    }
    
    public func configure(with model: UserModel){
        self.profilePicture.image = model.profilePicture
        self.userName.text = model.userName
        
        switch model.currentAction {
        case "add":
            accecptButton.alpha = 1
            accecptButton.setTitle("add", for: .normal)
            break
        case "request":
            accecptButton.alpha = 1
            rejectButton.alpha = 1
            break
        default:
            break
        }
        
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
