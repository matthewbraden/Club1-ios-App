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
import SVProgressHUD


class ClubViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var clubFeedTableView: UITableView!
    @IBOutlet weak var clubAddress: UILabel!
    @IBOutlet weak var clubCover: UILabel!
    @IBOutlet weak var clubUserCount: UILabel!
    
    var club : Clubs = Clubs()
    var clubID : [DataSnapshot] = [DataSnapshot]()
    var ref: DatabaseReference!
    let imageCache = NSCache<AnyObject, AnyObject>()

    var image : UIImage?
    var score : Int?
    var username : String?
    
    var photosArray : [Photo] = [Photo]()

    var textPassedOverName : String?
    var latPassedOver : Double?
    var longPassedOver : Double?
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        
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
        retrieveImage()
        
        SVProgressHUD.dismiss()
    }
    
    @IBAction func uberButton(_ sender: Any) {
    }
    
    
    //    MARK : - Tableview delegate method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customFeedCell", for: indexPath) as! ClubFeedTableViewCell
        
        let photo = photosArray[indexPath.row]
        cell.userSentPhoto.text = photo.sender
        cell.totalScore.text = String(photo.likes!)
        cell.cellDelegate = self
        cell.index = indexPath
        
//      Access the photo from the photos url
        if let photoURL = photo.imageURL {
            cell.imageTaken.image = nil
            if let cachedImage = imageCache.object(forKey: photoURL as AnyObject) as? UIImage {
                cell.imageTaken.image = cachedImage
            }
            else {
                let url = URL(string: photoURL)
                
                if let urlString = url {
                    URLSession.shared.dataTask(with: urlString) {
                        (data, response, error) in
                        if error != nil {
                            print("Download has hit an error with the url: \(error!)")
                            return
                        }
                        else {
                            DispatchQueue.main.async {
                                if let image = UIImage(data: data!) {
                                    self.imageCache.setObject(image, forKey: photoURL as AnyObject)
                                    cell.imageTaken.image = image
                                }
                            }
                        }
                    }.resume()
                }
            }
        }
        SVProgressHUD.dismiss()
        return cell
    }
    
    //    MARK : - Tableview datasource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    //    MARK : - Tableview did select row method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clubFeedTableView.deselectRow(at: indexPath, animated: true)
    }
    
    //    MARK : - Retrieve clubs from database function
    func retrieveClub() {
        
        var clubDB : DatabaseReference?
        clubDB = Database.database().reference()
        
        clubDB?.child("data/clubs").observe(.value, with: {
            (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let rest = rest.value as! Dictionary<String, Any>
                let name = rest["Name"]!
                let objectName = self.textPassedOverName!
                if objectName == name as! String {
                    let address = rest["Address"]!
                    let latitude = rest["Latitude"]!
                    let longitude = rest["Longitude"]!
                    let userCount = rest["UserPopulation"]!
                    
                    self.club.address = address as? String
                    self.club.latitude = latitude as! Double
                    self.club.longitude = longitude as! Double
                    self.club.name = self.textPassedOverName!
                    self.club.userPopulation = userCount as! Int
                    self.club.distance = 0.0
                    
                    self.clubCover.text = "Cover: $10-15"
                    self.clubAddress.text = "Address: \(self.club.address!)"
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


// MARK : - Upvote system code
extension ClubViewController : ClubFeedTableView {
    func onClickCell(index: Int) {
        
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
            
            let photo = Photo()
            photo.clubName = textPassedOverName!
            photo.image = image
            photo.sender = username!
            photo.likes = 0
            uploadImage(photo: photo)
        }
        SVProgressHUD.show()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //    MARK : - Saves the current users username
    func retrieveUser() {
        var userDB : DatabaseReference?
        userDB = Database.database().reference()
        
        let uid = Auth.auth().currentUser?.uid
        userDB?.child("data/users/\(uid!)").observe(.value, with: {
            (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            let userID = snapshotValue["Username"]!
            self.username = userID as? String
        })
    }
    
    //    MARK : - Uploads an image to firebase storage and firebase realtime database
    func uploadImage(photo : Photo) {
        
        let ref = Database.database().reference()
        let photoRef = ref.child("data/photos/\(textPassedOverName!)")
        print(textPassedOverName!)
        
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("club_images").child("\(photo.clubName!)").child("\(imageName).png")
        
        guard let uploadData = photo.image?.jpegData(compressionQuality: 0.75) else {
            print("upload data cannot be formed")
            return
        }
        
//        Closure for the putData function
        storageRef.putData(uploadData, metadata: nil) {
            (metadata, error) in
            var download : String?
            
            if error != nil {
                print("Error when putting data \(error!)")
                return
            }
            else {
//                Closure in order to get the download url
                storageRef.downloadURL {
                    (url, error) in
                    if error != nil {
                        print("Error getting download url \(error!)")
                        return
                    }
                    else {
                        download = url?.absoluteString
                        
//                        Metadata closure code must be in putData closure in order for the download url to work
                        guard let downloadURL = download else {
                            print("Error getting downlload url number \(error!)")
                            return
                        }
                        
//                        Uploads the data to the firebase realtime database
                        let photo = ["Name" : photo.clubName!, "User" : photo.sender!, "ImageUrl" : downloadURL, "PhotoScore" : photo.likes!] as [String : Any]
                        photoRef.childByAutoId().setValue(photo, withCompletionBlock: {
                            (error, reference) in
                            if error != nil {
                                print("Error sending to firebase realtime database")
                                return
                            }
                            else {
                                print("Photo has been added")
                            }
                        })
                    }
                }
            }
        }.resume()
    }
    
    //    MARK : - Function for retrieving the images for a specific club from the database
    func retrieveImage() {
        var photoDB : DatabaseReference?
        photoDB = Database.database().reference()
        
//        Searching for the photos with a specific club name
        photoDB?.child("data/photos/\(textPassedOverName!)").observe(.childAdded) {
            (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            let key = snapshot.key
            let name = snapshotValue["Name"]!
            let sender = snapshotValue["User"]!
            let imageURL = snapshotValue["ImageUrl"]!
            let likes = snapshotValue["PhotoScore"]!
        
            let photo = Photo()
            photo.clubName = name as? String
            photo.imageURL = imageURL as? String
            photo.sender = sender as? String
            photo.likes = likes as? Int
            photo.key = key
            
            self.photosArray.append(photo)
            self.clubFeedTableView.reloadData()
        }
    }
    
    func updateLikes(photo : Photo) {
        var photoDB : DatabaseReference?
        photoDB = Database.database().reference()
        let likesUpdate = ["PhotoScore" : photo.likes!]
        
        photoDB?.child("data/photos/\(photo.clubName!)/\(photo.key!)").updateChildValues(likesUpdate, withCompletionBlock: {
            (error, reference) in
            if error != nil {
                print("Error made when updating like value \(error!)")
            }
            else {
                print(reference)
            }
        })
    }
}
