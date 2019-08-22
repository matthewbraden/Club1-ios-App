//
//  ClubViewController.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-14.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import UberRides
import CoreLocation
import Vision


class ClubViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var clubFeedTableView: UITableView!
    @IBOutlet weak var clubAddress: UILabel!
    @IBOutlet weak var clubCover: UILabel!
    @IBOutlet weak var clubUserCount: UILabel!
    
    var club : Clubs = Clubs()
    var photo : Photo = Photo()
    var clubID : [DataSnapshot] = [DataSnapshot]()
    var ref: DatabaseReference!

    var image : UIImage?
    
    var username : String?
    
    var photoArray : [String] = ["Hi"]

    var textPassedOverName : String?
    var latPassedOver : Double?
    var longPassedOver : Double?
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        // Setup for the tableview
        clubFeedTableView.delegate = self
        clubFeedTableView.dataSource = self
       
        clubFeedTableView.register(UINib(nibName: "ClubFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "customFeedCell")
        
        clubFeedTableView.rowHeight = 386
        
        // Setup for the imagePicker
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        navigationItem.title = textPassedOverName!
        retrieveClub()
        retrieveUser()
    }
    
    @IBAction func uberButton(_ sender: Any) {
    }
    
    
    //    MARK : - Tableview delegate method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customFeedCell", for: indexPath) as! ClubFeedTableViewCell
        
        return cell
    }
    
    //    MARK : - Tableview datasource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    //    MARK : - Retrieve clubs from database function
    func retrieveClub() {
        
        var clubDB : DatabaseReference?
        var databaseHandle : DatabaseHandle?
        clubDB = Database.database().reference()
        
        clubDB?.child("data/clubs").observe(.value, with: {
            (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let rest = rest.value as! Dictionary<String, Any>
                let name = rest["Name"]!
                let objectName = self.textPassedOverName!
                if objectName as! String == name as! String {
                    let address = rest["Address"]!
                    let latitude = rest["Latitude"]!
                    let longitude = rest["Longitude"]!
                    let userCount = rest["UserPopulation"]!
//                    let photos = rest["Photos"]!
                    
                    self.club.address = address as! String
                    self.club.latitude = latitude as! Double
                    self.club.longitude = longitude as! Double
                    self.club.name = self.textPassedOverName!
                    self.club.userPopulation = userCount as! Int
                    self.club.distance = 0.0
//                    self.club.photos = photos as! [Photo]
                    
                    self.clubCover.text = "Cover: $10-15"
                    self.clubAddress.text = "Address: \(self.club.address)"
                    self.clubUserCount.text = "Users: \(self.club.userPopulation)"
                    
                    // MARK : - Configure the uber api call
//                    let button = RideRequestButton()
//                    let ridesClient = RidesClient()
//
//                    let pickupLocation = CLLocation(latitude: self.latPassedOver!, longitude: self.longPassedOver!)
//                    let dropoffLocation = CLLocation(latitude: self.club.latitude, longitude: self.club.longitude)
//
//                    let builder = RideParametersBuilder()
//                    builder.pickupLocation = pickupLocation
//                    builder.dropoffLocation = dropoffLocation
//                    builder.dropoffAddress = self.club.address
//                    builder.dropoffNickname = self.club.name
//
//                    button.rideParameters = builder.build()
//                    button.loadRideInformation()

//                    button.center = self.view.center
//                    self.view.addSubview(button)
                }
            }
        })
    }
}


// MARK : - Camera usage code
extension ClubViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //    MARK : - When the take picture button gets pressed
    @IBAction func takePictureButton(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    //    MARK : - Function that happens when the user is done taking the photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = userPickedImage
            
            photo.clubName = textPassedOverName!
            photo.image = image
            photo.sender = username!
            uploadImage(photo: photo)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //    MARK : - Saves the current users username
    func retrieveUser() {
        var userDB : DatabaseReference?
        var databaseHandle : DatabaseHandle?
        userDB = Database.database().reference()
        
        let uid = Auth.auth().currentUser?.uid
        userDB?.child("data/users/\(uid!)").observe(.value, with: {
            (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            let userID = snapshotValue["Username"]!
            self.username = userID as! String
        })
    }
    
    //    MARK : - Uploads an image to firebase storage and firebase realtime database
    func uploadImage(photo : Photo) {
        let ref = Database.database().reference()
        let photoRef = ref.child("data/photos")
        
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("club_images").child("\(photo.clubName)").child("\(imageName).png")
        
        guard let uploadData = photo.image?.jpegData(compressionQuality: 0.75) else {
            print("upload data cannot be formed")
            return
        }
        
        var download : String?
    
        storageRef.downloadURL {
            (url, error) in
            if error != nil {
                print("Error getting download url \(error)")
                return
            }
            else {
                download = url?.absoluteString
            }
        }
        
        storageRef.putData(uploadData, metadata: nil) {
            (metadata, error) in
            if error != nil {
                print("Error when putting data \(error)")
                return
            }
            else {
                guard let downloadURL = download else {
                    print("Error getting downlload url number \(error)")
                    return
                }
                let photo = ["Name" : photo.clubName, "User" : photo.sender, "ImageUrl" : downloadURL] as [String : Any]
                photoRef.updateChildValues(photo, withCompletionBlock: {
                    (error, reference) in
                    if error != nil {
                        print("Error sending to firebase realtime database")
                        return
                    }
                    else {
                        print(reference)
                    }
                })
            }
        }
    }
}
