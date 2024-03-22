//
//  UsersViewModel.swift
//  RealTime
//
//  Created by Marcus Grant on 1/5/24.
//

import Foundation
import Firebase
import FirebaseStorage

struct User: Identifiable, Equatable {
    let id: String
    let email: String
    let name: String
    var profileImageURL: String?
    var bannerImageURL: String?
    let friends: [String]
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

}


class UsersViewModel: ObservableObject {
    @Published var users = [User]()
    @Published var currentUser: User?
    @Published var friends = [User]() 
    
    
    private var db = Firestore.firestore()
    
    
    func fetchCurrentUser() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let userRef = db.collection("users").document(userID)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let id = document.documentID
                let email = data?["email"] as? String ?? ""
                let name = data?["name"] as? String ?? ""
                let profileImageURL = data?["imageUrl"] as? String
                let bannerImageURL = data?["bannerImageUrl"] as? String  // Added this line
                let friends = data?["friends"] as? [String] ?? []

                DispatchQueue.main.async {
                    // Ensure your User model has a bannerImageURL parameter in its initializer
                    self.currentUser = User(id: id, email: email, name: name, profileImageURL: profileImageURL, bannerImageURL: bannerImageURL, friends: friends)
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func fetchAllUsers() {
        db.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                self.users = querySnapshot?.documents.compactMap { document -> User? in
                    let data = document.data()
                    let id = document.documentID
                    let email = data["email"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let profileImageURL = data["imageUrl"] as? String
                    let bannerImageURL = data["bannerImageUrl"] as? String // Added line for banner image
                    let friends = data["friends"] as? [String] ?? []

                    return User(id: id, email: email, name: name, profileImageURL: profileImageURL, bannerImageURL: bannerImageURL, friends: friends) // Updated
                } ?? []
            }
        }
    }
    
    func fetchFriendsForCurrentUser(completion: @escaping () -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let userRef = db.collection("users").document(currentUserID)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let friendIDs = data?["friends"] as? [String] ?? []

                self.friends.removeAll()
                for friendID in friendIDs {
                    let friendRef = self.db.collection("users").document(friendID)
                    friendRef.getDocument { (friendDocument, error) in
                        if let friendDocument = friendDocument, friendDocument.exists {
                            let friendData = friendDocument.data()
                            let friend = User(
                                id: friendDocument.documentID,
                                email: friendData?["email"] as? String ?? "",
                                name: friendData?["name"] as? String ?? "",
                                profileImageURL: friendData?["imageUrl"] as? String,
                                bannerImageURL: friendData?["bannerImageUrl"] as? String,
                                friends: []  // Assuming friends field is not needed here.
                            )
                            DispatchQueue.main.async {
                                // Append each friend to the array.
                                self.friends.append(friend)
                            }
                        }
                    }
                }
                // Call the completion handler after all friends have been processed.
                DispatchQueue.main.async {
                    completion()
                }
            } else {
                print("Document does not exist")
                // Call the completion handler even if there's an error or the document does not exist.
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }





    
    
    func addFriend(toUserID userID: String, friendID: String) {
        let userRef = db.collection("users").document(userID)
        userRef.updateData([
            "friends": FieldValue.arrayUnion([friendID])
        ]) { error in
            if let error = error {
                print("Error adding friend: \(error.localizedDescription)")
            } else {
                print("Friend added successfully.")
            }
        }
    }


    
    func updateUserProfile(userID: String, age: Int, heightFeet: Int, heightInches: Int, weight: Int, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(userID)
        userRef.updateData([
            "age": age,
            "height": [
                "feet": heightFeet,
                "inches": heightInches
            ],
            "weight": weight
        ]) { error in
            if let error = error {
                print("Failed to update user profile: \(error)")
                completion(error)
            } else {
                print("User profile successfully updated!")
                completion(nil)
            }
        }
    }
    
    func uploadImage(_ image: UIImage, for user: User) { // No need to pass the whole viewModel
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            // Handle error: Failed to get JPEG representation of UIImage
            return
        }

        let storageRef = Storage.storage().reference().child("images/\(user.id).jpg")

        storageRef.putData(data, metadata: nil) { [weak self] (metadata, error) in
            if let error = error {
                // Handle error: Error occurred during upload
                print("Error uploading image: \(error)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    // Handle error: Couldn't retrieve download URL
                    print("Error getting download URL: \(error)")
                    return
                }
                
                if let url = url {
                    // Update the user document in Firestore with the image URL
                    let db = Firestore.firestore()
                    db.collection("users").document(user.id).updateData([ // Use updateData instead of setData for updating specific fields
                        "imageUrl": url.absoluteString
                    ]) { error in
                    db.collection("users").document(user.id).setData([
                        "imageUrl": url.absoluteString
                    ], merge: true) { error in
                        if let error = error {
                            // Handle error: Failed to update user document
                            print("Error saving image URL to Firestore: \(error)")
                        } else {
                            DispatchQueue.main.async {
                                // Update currentUser with a new instance of User
                                if let currentUser = self?.currentUser, currentUser.id == user.id {
                                    // Update the current user only if the uploaded image belongs to the logged-in user
                                    self?.currentUser = User(id: currentUser.id, email: currentUser.email, name: currentUser.name, profileImageURL: url.absoluteString, bannerImageURL: currentUser.bannerImageURL, friends: currentUser.friends)
                                }
                                // Additionally, update the 'users' array if it contains the user
                                if let index = self?.users.firstIndex(where: { $0.id == user.id }) {
                                    self?.users[index] = User(id: user.id, email: user.email, name: user.name, profileImageURL: url.absoluteString, bannerImageURL: user.bannerImageURL, friends: user.friends)
                                }
                                }
                            }
                        }
                    }
                }
            }
        }
            
    }
        
    
    func uploadBannerImage(_ image: UIImage, for user: User, in viewModel: UsersViewModel) {
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            // Handle error: Failed to get JPEG representation of UIImage
            return
        }
        
        let storageRef = Storage.storage().reference().child("bannerImages/\(user.id).jpg")
        
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                // Handle error: Error occurred during upload
                print("Error uploading banner image: \(error)")
                return
            }
            
            storageRef.downloadURL { [weak self] (url, error) in
                if let error = error {
                    // Handle error: Couldn't retrieve download URL
                    print("Error getting banner download URL: \(error)")
                    return
                }
                
                if let url = url {
                    // Update the user document in Firestore with the banner image URL
                    let db = Firestore.firestore()
                    db.collection("users").document(user.id).setData([
                        "bannerImageUrl": url.absoluteString
                    ], merge: true) { error in
                        if let error = error {
                            // Handle error: Failed to update user document
                            print("Error saving banner image URL to Firestore: \(error)")
                        } else {
                            // Successfully updated user document with banner image URL
                            DispatchQueue.main.async {
                                // Update currentUser with the new banner image URL
                                if let currentUser = self?.currentUser {
                                    self?.currentUser = User(id: currentUser.id, email: currentUser.email, name: currentUser.name, profileImageURL: currentUser.profileImageURL, bannerImageURL: url.absoluteString, friends: currentUser.friends)
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
