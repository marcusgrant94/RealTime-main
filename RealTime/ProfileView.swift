//
//  ProfileView.swift
//  RealTime
//
//  Created by Marcus Grant on 3/3/24.
//

import SwiftUI
import FirebaseStorage

struct ProfileView: View {
    let customColor = Color(red: 22 / 255.0, green: 29 / 255.0, blue: 35 / 255.0)
    @State private var isLoadingImage = false
    @EnvironmentObject var usersViewModel: UsersViewModel
    @State private var presentingStoryDetail = false
    @State private var showingBannerImagePicker = false
    @State private var profileImage: UIImage?
    @State private var inputImage: UIImage?
    @State private var bannerImage: UIImage? = nil
    @State private var selectedStory: Story?
    @State private var selectedUserStories: [Story]?
    
    private var profileImageView: some View {
        Group {
            if isLoadingImage {
                ActivityIndicatorView(isAnimating: $isLoadingImage, style: .large)
                    .frame(width: 100, height: 100) // Increased size
                    .background(Color.clear)
            } else if let profileImage = self.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Fill the frame while maintaining aspect ratio
                    .frame(width: 100, height: 100) // Increased size
                    .clipShape(RoundedRectangle(cornerRadius: 25)) // Adjusted corner radius for larger size
            } else {
                ProfilePlaceholder()
                    .frame(width: 100, height: 100) // Increased size
                    .clipShape(RoundedRectangle(cornerRadius: 25)) // Adjusted corner radius for larger size
            }
        }
    }


    var body: some View {
        ZStack {
            customColor
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) { // Ensure there is no spacing between elements in the VStack
                Button(action: {
                    self.showingBannerImagePicker = true
                }) {
                    ZStack {
                        if isLoadingImage {
                            ActivityIndicatorView(isAnimating: $isLoadingImage, style: .large)
                                .frame(width: 100, height: 100)
                                .background(Color.clear)
                        } else if let bannerImage = self.bannerImage {
                            Image(uiImage: bannerImage)
                                .resizable()
                                .scaledToFill() // Make sure the image fills the width
                                .frame(width: UIScreen.main.bounds.width, height: 110) // Adjust height as necessary
                                .clipped()
                        } else {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .scaledToFit() // Make sure the image fills the width
                                .frame(width: 50, height: 50)
                                .clipped()
                                .foregroundColor(.white)
                        }
                    }
                }
                .sheet(isPresented: $showingBannerImagePicker, onDismiss: loadBannerImage) {
                    ImagePicker(image: $inputImage)
                }
            }
            .offset(y: -320)
            VStack {
                            Spacer()
                            profileImageView
                    .offset(y: -177)
                Text(usersViewModel.currentUser?.name ?? "")
                    .offset(y: -185)
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding(.top, 8)
                            HStack(spacing: 70) {
                                Button(action: {}) {
                                    Text("Message")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.gray.opacity(0.5)) // Semi-transparent background
                                        .cornerRadius(10)
                                        .offset(y: -170)
                                }
                                Button(action: {}) {
                                    Text("Block")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.gray.opacity(0.5)) // Semi-transparent background
                                        .cornerRadius(10)
                                        .offset(y: -170)
                                }
                            }
                            .padding() // Add padding around the buttons if necessary
                            Spacer()
                
                
                        }
//            AchievementView()
                    }
        .onAppear {
            usersViewModel.fetchCurrentUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                loadImageFromURL()
                loadBannerImageFromURL()
            }
        }
                }
    
    private func getUserName(userId: String) -> String {
            usersViewModel.friends.first { $0.id == userId }?.name ?? "Unknown"
        }
    
    func loadBannerImageFromURL() {
        guard let user = usersViewModel.currentUser,
              let urlString = user.bannerImageURL,
              let url = URL(string: urlString) else {
            print("Banner URL formation failed. URL String: \(String(describing: usersViewModel.currentUser?.bannerImageURL))")
            return
        }

        isLoadingImage = true
        print("Loading banner image from URL: \(urlString)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingImage = false // Stop the loading indicator
            }
            if let error = error {
                print("Failed to load banner image: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Failed to load banner image: No HTTP response")
                return
            }
            print("HTTP Status Code: \(httpResponse.statusCode)")
            guard httpResponse.statusCode == 200 else {
                print("Failed to load banner image: HTTP Status Code \(httpResponse.statusCode)")
                return
            }
            guard let mimeType = httpResponse.mimeType else {
                print("Failed to load banner image: No MIME type provided")
                return
            }
            if !(mimeType.hasPrefix("image") || mimeType == "application/octet-stream" || mimeType == "text/plain") { // Add or remove conditions based on your needs
                print("Failed to load banner image: Invalid MIME type \(mimeType)")
                return
            }
            guard let data = data, !data.isEmpty else {
                print("Failed to load banner image: No data received")
                return
            }
            guard let image = UIImage(data: data) else {
                print("Failed to load banner image: Data could not be converted to UIImage")
                return
            }
            DispatchQueue.main.async {
                self.bannerImage = image
                print("Banner image successfully loaded and set")
            }
        }.resume()
    }




    
    func loadImageFromURL() {
        guard let user = usersViewModel.currentUser,
              let urlString = user.profileImageURL,
              let url = URL(string: urlString) else {
            print("URL formation failed")
            return
        }
        
        isLoadingImage = true
        print("Loading image from URL: \(urlString)")

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                    self.isLoadingImage = false
                    print("Image successfully loaded")
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoadingImage = false
                    print("Failed to load image from URL")
                }
            }
        }
    }

    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        self.profileImage = inputImage // Sets the locally chosen image so the UI can update immediately
        
        if let user = usersViewModel.currentUser {
            // Call uploadImage without the 'in' parameter
            usersViewModel.uploadImage(inputImage, for: user)
            
            // After updating the image in storage and Firestore, it's common to re-fetch the current user
            // to ensure all data is up-to-date, but consider if this is necessary or if you can update
            // just the necessary user data locally to avoid an unnecessary network request.
            usersViewModel.fetchCurrentUser() // Consider whether this call is needed based on your app's logic
        } else {
            print("No current user found for image upload")
        }
    }

    
    func loadBannerImage() {
        guard let inputBannerImage = self.inputImage else { return }
        self.bannerImage = inputBannerImage // Update the banner image to the newly selected one
        
        // Ensure we have a current user to upload the image for
        guard let currentUser = usersViewModel.currentUser else {
            print("No current user found for banner upload")
            return
        }
        
        // Call the function to upload the new banner image
        usersViewModel.uploadBannerImage(inputBannerImage, for: currentUser, in: usersViewModel)
        
        // Reset the input image for next use
        self.inputImage = nil
    }


            }

            struct CircleImageView: View {
                // Custom view for the circular profile image
                var body: some View {
                    Image("profile") // Replace with your profile image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100) // Adjust the size as needed
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4)) // White border
                        .shadow(radius: 10) // Optional: add shadow
                        .padding(.top, 150) // Adjust this padding to move the circle down to overlap the banner image
        }
                
                
                
                
                
    }
