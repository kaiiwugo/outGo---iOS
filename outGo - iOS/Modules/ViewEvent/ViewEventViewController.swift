//
//  ViewEventViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/2/21.
//

import UIKit
import MapKit

class ViewEventViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var popularityBar: UIProgressView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationMapview: MKMapView!
    @IBOutlet weak var endEventButton: UIButton!
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var tablewViewHeight: NSLayoutConstraint!
    
    //new
    @IBOutlet weak var attendanceLabel: UILabel!
    
    //constants
    let CELLBUFFER = 20
    var commentView = UIView()
    var commentTextField = UITextField()
    //vars
    var event: Event?
    var comments = [Comments]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBars()
        setUp()
        createCommentView()
        updateComments()
    }

    func setUp(){
        userIsHost()
        eventImage.contentMode = .scaleAspectFill
        //eventImage.layer.cornerRadius = 10
        eventImage.image = event?.properties.eventImage
        descriptionLabel.text = event?.properties.details
        DispatchQueue.main.async {
            do {
                try Utilities.shared.getAddress(Address: .standard, location: (self.event?.properties.eventLocation)!) { result in
                    //setsMap + Adress
                    self.locationMapview.isScrollEnabled = false
                    self.locationMapview.layer.cornerRadius = 10
                    self.locationMapview.setRegion(MKCoordinateRegion(center: (self.event?.properties.eventLocation2d)!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: false)
                    let annotation = MKPointAnnotation()
                    annotation.title = result
                    annotation.coordinate = (self.event?.properties.eventLocation2d)!
                    self.locationMapview.addAnnotation(annotation)
                }
            }
            catch {
                print(error)
            }
        }
        popularityBar.layer.cornerRadius = 5
        //comment table
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.allowsSelection = false
        self.commentsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        commentsTableView.register(CommentsTableViewCell.nib(), forCellReuseIdentifier: CommentsTableViewCell.identifier)
        userIsHost()
        getAttendance()
    }
    
    func setNavigationBars(){
        if event?.properties.eventType == "personal" {
            self.title = Utilities.shared.getTimePassed(postDate: (event?.properties.eventDate)! as NSDate)
        }
        else {
            self.title = "Now"
        }

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!]
        //Adds buttons
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    func userIsHost(){
        if UserDefaults.standard.string(forKey: "currentUser") == event?.properties.host {
            endEventButton.alpha = 1
        }
    }
    //The view that pops up when you cerate a comment
    func createCommentView(){
        //view
        let screenSize: CGRect = UIScreen.main.bounds
        commentView = UIView(frame: CGRect(x: 0, y: screenSize.height/2, width: contentView.frame.width, height: screenSize.height/2))
        commentView.backgroundColor = UIColor.systemBackground
        self.view.addSubview(commentView)
        commentView.alpha = 0
        //cancel Button
        let cancelButton = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 30))
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelComment), for: .touchUpInside)
        commentView.addSubview(cancelButton)
        //post Button
        let PostButton = UIButton(frame: CGRect(x: screenSize.width-70, y: 20, width: 60, height: 30))
        PostButton.setTitle("Post", for: .normal)
        PostButton.addTarget(self, action: #selector(postComment), for: .touchUpInside)
        commentView.addSubview(PostButton)
        //TextView
        let width = PostButton.frame.minX - cancelButton.frame.maxX - 10
        commentTextField = UITextField(frame: CGRect(x: 80, y: 20, width: width, height: 30))
        commentTextField.borderStyle = .roundedRect
        commentTextField.placeholder = "Add a comment"
        commentView.addSubview(commentTextField)
    }
    //brings up comment view
    @IBAction func createCommentButton(_ sender: Any) {
        commentView.alpha = 1
        commentTextField.becomeFirstResponder()
    }
    @objc func cancelComment(sender: UIButton!) {
        commentTextField.resignFirstResponder()
        commentTextField.text = nil
        commentView.alpha = 0
    }
    @objc func postComment(sender: UIButton!) {
        commentTextField.resignFirstResponder()
        DispatchQueue.main.async {
            let newComment = Comments(commentText: self.commentTextField.text!, commentUser: "Jerry", commentTime: Date())
            if self.event?.properties.eventType == "personal" {
                ViewEventHandler.shared.postComment(comment: newComment, collection: .events, postID: (self.event?.properties.postID)!)
            }
            else {
                ViewEventHandler.shared.postComment(comment: newComment, collection: .presets, postID: (self.event?.properties.postID)!)
            }
            self.updateComments()
            self.commentTextField.text = nil
        }
        commentView.alpha = 0
    }
    
    //Loads the comments into the table
    func updateComments(){
        FirestoreService.shared.getEventComments(postID: (self.event?.properties.postID)!) { result in
            self.comments = result
            self.commentsTableView.reloadData()
            self.updateView()
        }
    }
    
    func updateView(){
        let rowcount = comments.count + 2
        commentsTableView.isScrollEnabled = false
        tablewViewHeight.constant = commentsTableView.contentSize.height + CGFloat((rowcount*CELLBUFFER))
        let topSpace = commentsTableView.frame.minY
        let newheight = topSpace + commentsTableView.contentSize.height + CGFloat((rowcount*CELLBUFFER))
        contentViewHeight.constant = newheight
        self.commentsTableView.layoutIfNeeded()
        self.contentView.layoutIfNeeded()
    }
    
    @IBAction func endEventButton(_ sender: Any) {
        FirestoreService.shared.deleteEvent(postID: (self.event?.properties.postID)!)
        self.navigationController?.popViewController(animated: true)
    }

    
    func getAttendance(){
        ViewEventHandler.shared.getAttendance(postID: (self.event?.properties.postID)!, collection: .events) { strResult, intResult in
            self.attendanceLabel.text = strResult
            var popularity = Double(intResult) * 0.05 + 0.05
            self.popularityBar.setProgress(Float(popularity), animated: true)
        }
    }
  //  if event?.properties.eventType == "personal" {
    
}

extension ViewEventViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = commentsTableView.dequeueReusableCell(withIdentifier: CommentsTableViewCell.identifier, for: indexPath) as! CommentsTableViewCell
        let commentText = comments[index].commentText
        let commentUser = comments[index].commentUser
        //let commentTime = comments[index].commentTime
        cell.configure(with: CommentCell(profilePicture: UIImage(systemName: "face.smiling.fill")!, profileName: commentUser, comment: commentText))
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
}
