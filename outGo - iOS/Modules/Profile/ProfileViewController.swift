//
//  ProfileViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/24/21.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeImage: UIImageView!
    @IBOutlet weak var myCircleButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionTitleLabel: UILabel!
    @IBOutlet weak var myEventsCollectionView: UICollectionView!
    static let shared = ProfileViewController()
    var myEvents = [Event]()
    let currentUser = UserDefaults.standard.string(forKey: "currentUser")
    let groupName = UserDefaults.standard.string(forKey: "groupName")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigation()
        setButtons()
        setProfile()
        setCollection()
        loadMyEventsCollection()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setNavigation(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "RedFade"), for: .default)
        self.title = "Circle"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!, .foregroundColor: UIColor.white]
        //buttons
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(logoutButton))
        self.navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    func setButtons(){
        myCircleButton.tintColor = .white
        myCircleButton.layer.cornerRadius = myCircleButton.frame.width/2
        myCircleButton.clipsToBounds = true
        settingsButton.tintColor = .white
        settingsButton.layer.cornerRadius = settingsButton.frame.width/2
        settingsButton.clipsToBounds = true
        addButton.layer.cornerRadius = addButton.frame.width/2
        addButton.clipsToBounds = true
        addButton.tintColor = .white
        collectionTitleLabel.layer.cornerRadius = 5
        collectionTitleLabel.clipsToBounds = true
    }
    
    func setProfile(){
        profileImageButton.layer.cornerRadius = profileImageButton.frame.width/2
        profileImageButton.clipsToBounds = true
        badgeView.alpha = 0
        userNameLabel.text = currentUser
        if groupName != "" {
            badgeView.layer.cornerRadius = badgeView.frame.width/2
            badgeView.clipsToBounds = true
            badgeView.alpha = 1
        }
    }
    
    func setCollection(){
        myEventsCollectionView.layer.cornerRadius = 10
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        myEventsCollectionView.backgroundColor = .clear
        myEventsCollectionView.showsHorizontalScrollIndicator = false
        myEventsCollectionView.collectionViewLayout = layout
        myEventsCollectionView.dataSource = self
        myEventsCollectionView.delegate = self
        myEventsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        myEventsCollectionView.register(ExplorePageCollectionViewCell.nib(), forCellWithReuseIdentifier: ExplorePageCollectionViewCell.identifier)
    }
    
    func loadMyEventsCollection(){
        ProfileHandler.shared.getMyEvents(user: currentUser!) { result in
            DispatchQueue.main.async {
                self.myEvents = result
                self.myEventsCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func profileImageButton(_ sender: Any) {
        
    }
    
    
    @IBAction func myCircleButton(_ sender: Any) {
        let circleVC = CircleViewController(nibName: "CircleViewController", bundle: nil)
        show(circleVC, sender: self)
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        let affiliationVC = AffiliationsViewController(nibName: "AffiliationsViewController", bundle: nil)
        show(affiliationVC, sender: self)
    }
    
    @IBAction func addFriendButton(_ sender: Any) {
        let addVC = AddFriendViewController(nibName: "AddFriendViewController", bundle: nil)
        show(addVC, sender: self)
    }
    
    @objc func logoutButton(sender: UIBarButtonItem) {
        let settingsvc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        settingsvc.modalPresentationStyle = .popover
        settingsvc.modalTransitionStyle = .coverVertical
        present(settingsvc, animated: true, completion: nil)
    }

    
    @IBAction func adminPowers(_ sender: Any) {
        AdminAddPresets.shared.addEvent()
    }

}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        myEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myEventsCollectionView.dequeueReusableCell(withReuseIdentifier: ExplorePageCollectionViewCell.identifier, for: indexPath) as! ExplorePageCollectionViewCell
        let index = indexPath.row
        let event = myEvents[index]
        let eventImage = event.properties.eventImage
        let timePassed = Utilities.shared.getTimePassed(postDate: event.properties.eventDate as NSDate)
        let distance = event.current.distance
        cell.configure(with: ExploreEventCell(eventImage: eventImage, timeSincePost: timePassed, distance: distance, eventType: event.properties.eventType, friendEvent: event.visability.friendEvent, groupEvent: event.visability.groupEvent))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let ViewEventeVC = ViewEventViewController(nibName: "ViewEventViewController", bundle: nil)
        ViewEventeVC.event = myEvents[index]
        show(ViewEventeVC, sender: self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 200)
    }
    
    
    
}
