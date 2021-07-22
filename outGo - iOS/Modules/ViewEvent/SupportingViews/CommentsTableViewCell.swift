//
//  CommentsTableViewCell.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/2/21.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var profileName: UILabel!
    @IBOutlet var comment: UILabel!
    static let identifier = "CommentsTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.clipsToBounds = true
        profilePicture.layer.cornerRadius = profilePicture.bounds.size.width/2
    }
    
    public func configure(with model: CommentCell){
        profilePicture.image = model.profilePicture
        profileName.text = model.profileName
        comment.text = model.comment
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "CommentsTableViewCell", bundle: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
            let margins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
    }
    
}
