//
//  AddFriendViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/12/21.
//

import UIKit
import AVFoundation
import Foundation

class AddFriendViewController: UIViewController {
    //serach
    @IBOutlet weak var requestsButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userSearchTableView: UITableView!
    var requestedUsers = [String]()
    var userInfo = [UserProfile]()
    var userNames = [String]()
    var searchedUser = [String]()
    var searching = false
    //qrcode
    let currentUser = UserDefaults.standard.string(forKey: "currentUser")
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addByScannerView: UIView!
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var myQrCodeImage: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        setTable()
        setNavigation()
        loadUsers()
        checkRequests()
        setMyQRCode()
        searchBar.setImage(UIImage(systemName: "qrcode"), for: .bookmark, state: .normal)
    }
    func setNavigation(){
        self.title = "Circle"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!]
        requestsButton.alpha = 0.25
        requestsButton.isEnabled = false
    }
    func setTable(){
        userSearchTableView.dataSource = self
        userSearchTableView.delegate = self
        self.userSearchTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        userSearchTableView.register(UsersTableViewCell.nib(), forCellReuseIdentifier: UsersTableViewCell.identifier)
        searchBar.delegate = self
    }
    func loadUsers(){
        FriendingHandler.shared.getAllUsers { result in
            self.userInfo = result
            result.forEach { user in
                self.userNames.append(user.userName)
            }
            self.userSearchTableView.reloadData()
        }
    }
    
    func checkRequests(){
        FriendingHandler.shared.allRequestCheck { result in
            if result.isEmpty == false {
                self.requestedUsers = result
                self.requestsButton.alpha = 1
                self.requestsButton.isEnabled = true
            }
        }
    }
    
    @IBAction func newFriendButton(_ sender: Any) {
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        let friendRequestVC = FriendRequestViewController(nibName: "FriendRequestViewController", bundle: nil)
        friendRequestVC.requestedUsers = requestedUsers
        show(friendRequestVC, sender: self)
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        userNameLabel.text = "My Code" //currentUser
        addByScannerView.alpha = 1
        startScan()
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        addByScannerView.alpha = 0
        successView.alpha = 0
    }
    
    func closeKeyboards(){
        self.view.endEditing(false)
    }
}

extension AddFriendViewController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return searchedUser.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userSearchTableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.identifier, for: indexPath) as! UsersTableViewCell
        cell.selectionStyle = .none
        let image = UIImage(systemName: "face.smiling.fill")!
        if searching {
           let userName = searchedUser[indexPath.row]
            let user = userInfo.first { user in
                user.userName == userName
            }
            cell.configure(with: UserSearchModel(profilePicture: image, userName: userName, currentAction: "add", isFriend: user!.isFriend))
            return cell
        }
        else {
            
            return cell
        }
    }
    //Handles the table for the search bar
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(false)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

extension AddFriendViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searching = true
        if searchText == "" {
            searchedUser = []
        }
        else {
            searchedUser = userNames.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        }
        userSearchTableView.alpha = 1
        userSearchTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = nil
        userSearchTableView.alpha = 0
        closeKeyboards()
        userSearchTableView.reloadData()
    }
    
}

extension AddFriendViewController: AVCaptureMetadataOutputObjectsDelegate {
    func startScan(){
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = scannerView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scannerView.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        dismiss(animated: true)
    }

    func found(code: String) {
        let friendName = code

        FriendingHandler.shared.checkUserExists(user: friendName) { result in
            if result == true {
                FriendingHandler.shared.addFriend(friendName: friendName)
                self.checkImage.alpha = 1
                self.showMessage(text: "Added \(friendName) to circle")
            }
            else {
                self.checkImage.alpha = 0
                self.showMessage(text: "Couldn't find '\(friendName)'")
            }

        }

    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    func showMessage(text: String){
        successView.alpha = 1
        successLabel.text = text
    }

    func setMyQRCode(){
        let data = self.currentUser!.data(using: .ascii, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10 )
        let image = UIImage(ciImage: (filter?.outputImage)!.transformed(by: transform))
        myQrCodeImage.image = image

        //sets elements
        cancelButton.layer.cornerRadius = 10
        cancelButton.backgroundColor = UIColor.secondarySystemBackground
        cancelButton.tintColor = .label
    }

}
