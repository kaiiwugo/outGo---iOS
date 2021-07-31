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
import iCarousel

class CreateEventViewController: UIViewController, UITextViewDelegate {
    enum Collection: String {
        case all = "All Events"
        case properties = "Properties"
    }
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    let locationManager = CLLocationManager()
    var imageData = Data()
    var eventType = "social"
    //outlets
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var publicSwitch: UISwitch!
    @IBOutlet weak var publicLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var carouselView: UIView!
    @IBOutlet weak var eventTypeCarousel: iCarousel!
    @IBOutlet weak var eventTypeLabel: UILabel!
    
    let currentUser = UserDefaults.standard.string(forKey: "currentUser")
    let groupName = UserDefaults.standard.string(forKey: "groupName")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        setNavigationBars()
        setUp()
        setMap()
        setupCarousel()
        setgroup()
    }
    
    func setgroup(){
    }

    func setupCarousel(){
        eventTypeCarousel.dataSource = self
        eventTypeCarousel.delegate = self
        carouselView.layer.cornerRadius = carouselView.frame.width/2
        carouselView.layer.borderWidth = 3
        carouselView.backgroundColor = UIColor.label.withAlphaComponent(0.25)
        carouselView.layer.borderColor = UIColor.separator.cgColor
        eventTypeCarousel.type = .rotary
    }
    func setUp(){
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact
        datePicker.minuteInterval = 30
        datePicker.minimumDate = datePicker.date
        imageButton.layer.cornerRadius = 5
        imageButton.layer.borderWidth = 1
        imageButton.layer.borderColor = UIColor.separator.cgColor
        detailsTextView.layer.cornerRadius = 5
        detailsTextView.textColor = .lightGray
        detailsTextView.text = "add details"
        detailsTextView.delegate = self
        
    }
    
    func setMap(){
        mapView.delegate = self
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
        let eventDetails = detailsTextView.text
        let eventDate = datePicker.date
        let host = currentUser
        var imageURL = ""
        var isActive = true
        let eventLatitude = self.mapView.centerCoordinate.latitude
        let eventLongitude = self.mapView.centerCoordinate.longitude
        if round(Date().timeIntervalSince(datePicker.date as Date)) < 0 {
            isActive = false
        }
        DispatchQueue.main.async {
            CreateHandler.shared.getImageURL(imageData: self.imageData ?? Data(), date: eventDate) { result in
                let eventDocument = self.db.collection(Collection.all.rawValue).document()//.collection(Collection.properties.rawValue).document()
                eventDocument.setData(["comments": [], "coordinates": ["latitude": eventLatitude, "longitude": eventLongitude], "properties": ["details": eventDetails, "host": host, "imageURL": result, "eventDate": eventDate, "postID": eventDocument.documentID, "eventType": self.eventType], "current": ["distance": 0, "isPublic": self.publicSwitch.isOn, "attendance": 0, "viewDistance": 0, "isActive": isActive]])
            }
        }
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func locationButton(_ sender: Any) {
        mapView.isUserInteractionEnabled = true
    }
    
    @IBAction func imageButton(_ sender: Any) {
        takePicture()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        print("called")
        if detailsTextView.text == "add details" && detailsTextView.isFirstResponder {
            detailsTextView.text = nil
            detailsTextView.textColor = .white
        }
    }
    
    func textViewDidEndEditing (textView: UITextView) {
        if detailsTextView.text.isEmpty || detailsTextView.text == "" {
            detailsTextView.textColor = .lightGray
            detailsTextView.text = "add details"
        }
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
extension CreateEventViewController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        if groupName != "" {
            return 4
        }
        else {
            return 3
        }
    }
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: carouselView.bounds)
        view.layer.cornerRadius = view.frame.width/2
        let imageView = UIImageView(frame: view.bounds)
        view.addSubview(imageView)
        view.contentMode = .scaleAspectFill
        
        switch index {
        case 0:
            imageView.image = UIImage(named: "RedPin")
        case 1:
            imageView.image = UIImage(named: "GreenPin")
        case 2:
            imageView.image = UIImage(named: "YellowPin")
        case 3:
            imageView.clipsToBounds = true
            imageView.image = UIImage(named: "TempleLogo")
            imageView.contentMode = .scaleAspectFit
            
         
        default:
            imageView.image = UIImage(named: "RedPin")
        }
        return view
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        switch eventTypeCarousel.currentItemIndex {
        case 0:
            eventType = "social"
            eventTypeLabel.text = "Social"
            publicSwitch.isEnabled = true
            publicLabel.text = "Public"
        case 1:
            eventType = "community"
            eventTypeLabel.text = "Community"
            publicSwitch.isEnabled = true
            publicLabel.text = "Public"
        case 2:
            eventType = "active"
            eventTypeLabel.text = "Active"
            publicSwitch.isEnabled = true
            publicLabel.text = "Public"
        case 3:
            publicSwitch.isEnabled = false
            publicLabel.text = "Temple"
            
        default:
            "social"
        }
        
    }
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch (option) {
            case .spacing: return 2
            default: return value
        }
    }
}


extension CreateEventViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let viewLocation2D = mapView.centerCoordinate
        let viewLocation = CLLocation(latitude: viewLocation2D.latitude, longitude: viewLocation2D.longitude)
        do {
            try Utilities.shared.getAddress(Address: .standard, location: viewLocation) { result in
                self.adressLabel.text = result
            }
        }
        catch {
            print(error)
        }
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        let viewLocation2D = mapView.centerCoordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = viewLocation2D
        mapView.addAnnotation(annotation)
    }

}
