//
//  ProfileView.swift
//  RealTime
//
//  Created by Marcus Grant on 3/1/24.
//

import SwiftUI

struct HomeView: View {
    let customColor = Color(red: 22 / 255.0, green: 29 / 255.0, blue: 35 / 255.0)
    @State private var post = ""
    @State private var isLoadingImage = false
    @State private var isUserDataLoaded = false
    @EnvironmentObject var storiesViewModel: StoriesViewModel
    @EnvironmentObject var usersViewModel: UsersViewModel
    @State private var presentingStoryDetail = false
    @State private var profileImage: UIImage?
    @State private var inputImage: UIImage?
    @State private var selectedStory: Story?
    @State private var selectedUserStories: [Story]?
    
    private var profileImageView: some View {
        Group {
            if isLoadingImage {
                ActivityIndicatorView(isAnimating: $isLoadingImage, style: .large)
                    .frame(width: 50, height: 50) // Further reduced size
                    .background(Color.clear)
            } else if let profileImage = self.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Fill the frame while maintaining aspect ratio
                    .frame(width: 50, height: 50) // Further reduced size
                    .clipShape(RoundedRectangle(cornerRadius: 12)) // Adjusted corner radius for smaller size
            } else {
                ProfilePlaceholder()
                    .frame(width: 50, height: 50) // Further reduced size
                    .clipShape(RoundedRectangle(cornerRadius: 12)) // Adjusted corner radius for smaller size
            }
        }
    }



    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        
                        Spacer()
                    }
                    HStack {
                        Text("\(self.partOfDay()) \(usersViewModel.currentUser?.name ?? "")")

                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                            .frame(height: 100)
                        Spacer()
                        
                    }
                    HStack {
                        Text("\(self.shareYourTime())")
                            .fontWeight(.thin)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                            .offset(y: -40)
                        Spacer()
                    }
                    HStack {
                        profileImageView
                            .padding(.horizontal)
                            .padding(.vertical)
                            .offset(y: -40)
                        TextField("Post a caption", text: $post)
                            .foregroundColor(.white)
                            .fontWeight(.regular)
                            .padding()
                            .frame(width: 210)
                            .overlay(
                                RoundedRectangle(cornerRadius: 13)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .offset(y: -39)
                        Spacer()
                    }
                    VStack() {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 15) {
                                // Explicitly specify the data type for the ForEach loop
                                ForEach(usersViewModel.friends, id: \.id) { (friend: User) in
                                    if let stories = storiesViewModel.stories[friend.id], !stories.isEmpty {
                                        Button(action: {
                                            selectedUserStories = stories
                                            presentingStoryDetail = true
                                        }) {
                                            StoryThumbnailView(friend: friend, stories: stories)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                           
                            
                        }
                        
                        .edgesIgnoringSafeArea(.horizontal)
                        .offset(y: -40)
                    }
                    .refreshable {
                        refreshStories()
                    }
                    
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Image("bell")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .padding(.horizontal)
                        }
                    
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gear")
                                    .foregroundStyle(.white)
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 100)
                        }
                    }
                    .background(customColor.edgesIgnoringSafeArea(.all))
                    .refreshable {
                        refreshStories()
                    }
                    .sheet(isPresented: $presentingStoryDetail) {
                        if let stories = selectedUserStories {
                            StoriesCarouselView(stories: stories)
                        }
                    }
                    .background(customColor.edgesIgnoringSafeArea(.all))
//                    .onAppear {
//                        usersViewModel.fetchFriendsForCurrentUser() { // Assuming fetchFriendsForCurrentUser has a completion handler.
//                            DispatchQueue.main.async {
//                                let friendIds = usersViewModel.friends.map { $0.id }
//                                storiesViewModel.fetchStoriesForUsers(userIds: friendIds)
//                                // Add any additional operations that should happen after friends are fetched.
//                            }
//                        }
//                    }

                    
                    CustomSegmentedPicker()
                        .padding()
                        .offset(y: -50)
                    Spacer()
                    ForEach(usersViewModel.friends, id: \.id) { friend in
                                            // Check if there are storylines for this friend
                                            if let storylines = storiesViewModel.storylines[friend.id], !storylines.isEmpty {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    Text(friend.name) // Friend's name as a section header
                                                        .font(.headline)
                                                        .padding(.leading)
                                                    
                                                    ForEach(storylines, id: \.id) { storyline in
                                                        StorylineCardView(storyline: storyline)
                                                            .padding(.horizontal)
                                                            .environmentObject(usersViewModel) // Pass the UsersViewModel
                                                    }
                                                }
                                            }
                                        }
                }
                
            }
            .background(customColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 22/255.0, green: 29/255.0, blue: 35/255.0, alpha: 1) // Match your customColor
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            usersViewModel.fetchCurrentUser()
                usersViewModel.fetchFriendsForCurrentUser() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let friendIds = usersViewModel.friends.map { $0.id }
                        storiesViewModel.fetchStoriesForUsers(userIds: friendIds)
                        storiesViewModel.fetchStorylinesForFriends(friends: usersViewModel.friends)
                        loadImageFromURL()
                    }
                }
            }
        .refreshable {
            // Only include the actions that should happen when the user manually refreshes
            let friendIds = usersViewModel.friends.map { $0.id }
            storiesViewModel.fetchStoriesForUsers(userIds: friendIds)
            storiesViewModel.fetchStorylinesForFriends(friends: usersViewModel.friends)
        }


    }
    
    
    
    private func getUserName(userId: String) -> String {
            usersViewModel.friends.first { $0.id == userId }?.name ?? "Unknown"
        }
    
    private func refreshStories() {
        usersViewModel.fetchFriendsForCurrentUser { // Removed [weak self] here
            // If you need to access properties or methods of the view struct, just use them directly.
            // For SwiftUI views, there's typically no risk of a retain cycle in this context.
            
            let friendIds = self.usersViewModel.friends.map { $0.id }
            self.storiesViewModel.fetchStoriesForUsers(userIds: friendIds)
        }
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
        self.profileImage = inputImage // Sets the chosen image so the UI can update immediately.
        
        if let user = usersViewModel.currentUser {
            // Upload the image for the current user.
            usersViewModel.uploadImage(inputImage, for: user)
            
            // Optional: If you want to refresh user data after image upload, consider doing it in the completion handler of uploadImage.
            // But make sure 'uploadImage' has a completion block if you want to use this.
            // Otherwise, you can call fetchCurrentUser directly like this, but it will not guarantee that it runs after the upload is complete.
            usersViewModel.fetchCurrentUser() // Refresh user data.
        } else {
            print("No current user found for image upload")
        }
    }

    
    func partOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.minute, from: Date())

        // Convert time to a format that's easier to compare
        let currentTime = hour * 60 + minute // Convert hours to minutes

        // Define time ranges
        let morningEnd = 11 * 60 + 30  // 11:30 AM
        let afternoonEnd = 13 * 60     // 1:00 PM
        let eveningEnd = 23 * 60 + 30  // 11:30 PM

        // Determine part of the day
        if currentTime <= morningEnd {
            return "Good morning"
        } else if currentTime <= afternoonEnd {
            return "Good afternoon"
        } else if currentTime <= eveningEnd {
            return "Good evening"
        } else {
            return "Good night"
        }
    }
    
    func shareYourTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Determine the time of day based on the hour
        if hour >= 7 && hour < 17 { // From 7:00 AM to 4:59 PM
            return "Share your day with us!"
        } else { // From 5:00 PM to 6:59 AM
            return "Share your night with us!"
        }
    }


    
    
}
