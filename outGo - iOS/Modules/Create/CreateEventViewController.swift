//
//  CreateEventViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/17/21.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseStorage

class CreateEventViewController: UIViewController {
    enum Collection: String {
        case all = "All Events"
        case properties = "Properties"
    }
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    let locationManager = CLLocationManager()
    var imageData = Data()
    //outlets
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var DetailsTextView: UITextField!
    @IBOutlet weak var publicSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapHighlight: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBars()
        setUp()
    }
    
    func setUp(){
        locationButton.setTitle("Current Location", for: .normal)
        imageButton.setTitle("Add", for: .normal)
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact
        datePicker.minuteInterval = 30
        datePicker.minimumDate = datePicker.date
        //setsMap
        mapView.isUserInteractionEnabled = false
        mapView.layer.cornerRadius = 10
        let location = locationManager.location
        let location2d  = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        self.mapView.setRegion(MKCoordinateRegion(center: location2d, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = (location2d)
        self.mapView.addAnnotation(annotation)
    }

    func setNavigationBars(){
        //sets navigation bar
        self.title = "New Event"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(postButton))
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func postButton(sender: UIBarButtonItem) {
        let eventDetails = DetailsTextView.text
        let eventDate = datePicker.date
        let location = locationManager.location
        let host = UserDefaults.standard.string(forKey: "currentUser")
        var imageURL = ""
        var isActive = true
        if round(Date().timeIntervalSince(datePicker.date as Date)) < 0 {
            isActive = false
        }
        DispatchQueue.main.async {
            CreateHandler.shared.getImageURL(imageData: self.imageData ?? Data(), date: eventDate) { result in
                let eventDocument = self.db.collection(Collection.all.rawValue).document()//.collection(Collection.properties.rawValue).document()
                eventDocument.setData(["comments": [], "coordinates": ["latitude": location?.coordinate.latitude, "longitude": location?.coordinate.longitude], "properties": ["details": eventDetails, "host": host, "imageURL": result, "eventDate": eventDate, "postID": eventDocument.documentID, "eventType": "personal"], "current": ["distance": 0, "isPublic": self.publicSwitch.isOn, "attendance": 0, "viewDistance": 0, "isActive": isActive]])
            }
        }
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func locationButton(_ sender: Any) {
        mapHighlight.alpha = 1
        mapView.isUserInteractionEnabled = true
    }
    
    
    @IBAction func imageButton(_ sender: Any) {
        takePicture()
    }
    
}

extension CreateEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func takePicture() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        imageButton.contentMode = .scaleAspectFill
        imageButton.setImage(image, for: .normal)
        imageData = image.jpegData(compressionQuality: 1)!
    }
    
}
