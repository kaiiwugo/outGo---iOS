//
//  ExplorePageCollectionViewCell.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/27/21.
//

import UIKit

class ExplorePageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var eventImage: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var distance: UIButton!
    @IBOutlet var eventType: UIImageView!
    @IBOutlet var friendImage: UIImageView!
    static let identifier = "ExplorePageCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        distance.setBackgroundImage(UIImage(named: "BlueFade"), for: .normal)
        distance.layer.cornerRadius = 10
        distance?.layer.masksToBounds = true
        distance.tintColor = .black
        self.eventImage.contentMode = .scaleAspectFill
        eventImage.layer.cornerRadius = 10
        eventType.layer.cornerRadius = eventImage.layer.cornerRadius
    }
    
    public func configure(with model: ExploreEventCell){
        self.eventImage.image = model.eventImage
        self.timeLabel.text = model.timeSincePost
        self.distance.setTitle("\(model.distance) mi", for: .normal)
        
        switch model.friendEvent {
        case true:
            friendImage.alpha = 1
        default:
            friendImage.alpha = 0
        }
        
        switch model.eventType {
        case "social":
            self.eventType.image = UIImage(named: "RedFadeUp")
            break
        case "community":
            self.eventType.image = UIImage(named: "GreenFadeUp")
            break
        case "active":
            self.eventType.image = UIImage(named: "YellowFadeUp")
            break
        default:
            self.eventType.image = UIImage(named: "RedFadeUp")
            break
        }
        
    }

    static func nib() -> UINib {
        return UINib(nibName: "ExplorePageCollectionViewCell", bundle: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
    }
}
