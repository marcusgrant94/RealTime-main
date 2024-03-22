//
//  CameraView.swift
//  RealTime
//
//  Created by Marcus Grant on 11/21/23.
//

import SwiftUI
import AVFoundation
import AVKit
import Firebase

struct CameraView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var usersViewModel: UsersViewModel
    @EnvironmentObject var navigationState: NavigationState
    @StateObject private var viewModel = CameraViewModel()
    var profileImageURL: String?
    @State private var showCapturedPhoto = false
    @State private var inputImage: UIImage?
    @State private var showCapturedStories = false
    @State private var profileImage: UIImage?
    @State private var isLoadingImage = false
    @State private var isCapturing = false
    @State private var isUserDataLoaded = false
    @State private var capturedPhoto: UIImage?
    @State private var showUploadButton = false
    @State private var showFriendsList = false
    @State private var showEditButton = false

    var body: some View {
        ZStack {
            CameraPreview(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
                .blur(radius: isCapturing ? 10 : 0)
            
            VStack {
                HStack {
                    Spacer()
                    cameraSwitchButton
                }
                .padding(.top, 44)
                .padding(.trailing, 20)
                
                Spacer()
            }
            
            if let capturedPhoto = capturedPhoto {
                Image(uiImage: capturedPhoto)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        navigationState.isTabBarHidden = true
                    }
                    .onTapGesture {
                        self.capturedPhoto = nil
                        showCapturedPhoto = false
                        viewModel.showUploadButton = false
                        // Explicitly set tabBar visibility when photo is dismissed
                        navigationState.isTabBarHidden = false
                    }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if showEditButton {
                            editButton
                        }
                    }
                    .offset(x: -75, y: -55)
                    .padding()
                }
                
                
                if viewModel.showUploadButton {
                    VStack {
                        Spacer()
                        HStack {
                            uploadButton
                            sendToButton
                            cancelButton
                        }
                        .padding(.bottom, 30)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
            } else {
                cameraUI
            }
        }
        .onAppear {
            // Configure the appearance of the navigation bar
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 22/255.0, green: 29/255.0, blue: 35/255.0, alpha: 1)
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            // Fetch the current user and other initial actions
            usersViewModel.fetchCurrentUser()
            loadImageFromURL()  // Make sure this function is defined elsewhere in your code.
            navigationState.isTabBarHidden = false
        }
        .onChange(of: usersViewModel.currentUser) { _ in
            // React to changes in the current user
            if usersViewModel.currentUser != nil {
                isUserDataLoaded = true  // Make sure 'isUserDataLoaded' is defined in your state.
            }
        }
        .onChange(of: isUserDataLoaded) { isLoaded in
            // React to changes in the 'isUserDataLoaded' state
            if isLoaded {
                loadImageFromURL()  // Again, ensure this function exists.
            }
        }
        .onDisappear {
            // Perform any cleanup or state updates needed when the view disappears
            navigationState.isTabBarHidden = false
        }
    }
    
    private var cameraSwitchButton: some View {
        Button {
            viewModel.switchCamera()
        } label: {
            Image(systemName: "camera.rotate")
                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.black.opacity(0.7)))
        }
    }
    
    
    private var sendToButton: some View {
        Button("Send to") {
            showFriendsList = true
        }
        .padding()
        .background(Color.green)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .sheet(isPresented: $showFriendsList) {
            FriendsListView(capturedPhoto: capturedPhoto, usersViewModel: usersViewModel, cameraViewModel: CameraViewModel(), isPresented: $showFriendsList)
        }
    }


    private var cameraUI: some View {
        VStack {
            HStack {
                Button(action: {
                    showCapturedStories.toggle()
                }) {
                    profileImageView
                }
                .offset(x: -150, y: 40)
                .padding(.top)
                .sheet(isPresented: $showCapturedStories) {
                    CapturedStoriesView()
                }
            }

            Spacer()

            Button(action: capturePhoto) {
                Image(systemName: "camera")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(Color.black.opacity(0.7)))
            }
            .offset(y: -10)
            .padding(.bottom, 105)
        }
    }

    private var uploadButton: some View {
        Button("Upload to Stories") {
            if let userID = authViewModel.currentUserId {
                viewModel.uploadPhotoToStories(userID: userID)
            }
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var cancelButton: some View {
        Button("Cancel") {
            self.capturedPhoto = nil
            viewModel.showUploadButton = false
            navigationState.isTabBarHidden = false
        }
        .padding()
    }
    
    private var editButton: some View {
        Button(action: {
            // Action to present photo editing view
            // You need to implement the photo editing functionality
        }) {
            Image(systemName: "pencil")
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(Circle().fill(Color.black.opacity(0.7)))
        }
    }

    private func capturePhoto() {
        isCapturing = true
        viewModel.capturePhoto()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let capturedImage = viewModel.capturedImage {
                self.showCapturedPhoto = true
                self.capturedPhoto = capturedImage
                viewModel.showUploadButton = true
                self.showEditButton = true
            }
            isCapturing = false
        }
    }

    var profileImageView: some View {
        Group {
            if isLoadingImage {
                ActivityIndicatorView(isAnimating: $isLoadingImage, style: .large)
                    .frame(width: 50, height: 50) // Adjust based on your UI needs
            } else if let uiImage = self.profileImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Or use .fit based on your UI needs
                    .frame(width: 50, height: 50) // Adjust based on your UI needs
                    .clipShape(Circle())
            } else {
                // Show a placeholder if no image is available
                ProfilePlaceholder() // Make sure this is defined or use an alternative placeholder
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
        }
        .onAppear {
            loadImageFromURL()
        }
    }
    

    private func loadImageFromURL() {
        guard let urlString = usersViewModel.currentUser?.profileImageURL,
              let url = URL(string: urlString) else {
            return
        }

        isLoadingImage = true
        print("Loading profile image from URL: \(urlString)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingImage = false // Stop the loading indicator
            }
            if let error = error {
                print("Failed to load profile image: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Failed to load profile image: HTTP Status Code \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                return
            }
            guard let mimeType = httpResponse.mimeType, mimeType.hasPrefix("image") || mimeType == "application/octet-stream" else {
                print("Failed to load profile image: Invalid MIME type \(String(describing: httpResponse.mimeType))")
                return
            }
            guard let data = data, !data.isEmpty, let image = UIImage(data: data) else {
                print("Failed to load profile image: No data received or data could not be converted to UIImage")
                return
            }
            DispatchQueue.main.async {
                self.profileImage = image
                print("Profile image successfully loaded and set")
            }
        }.resume()
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.profileImage = UIImage(data: data)
                    isLoadingImage = false
                }
            } else {
                DispatchQueue.main.async {
                    isLoadingImage = false
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

}

struct CapturedImageView: View {
    @Binding var capturedImage: UIImage?
    var onDismiss: () -> Void
    var onSave: (UIImage) -> Void
    @EnvironmentObject var viewModel: CameraViewModel

    var body: some View {
        ZStack {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .offset(y: 40)
                                .font(.largeTitle)
                                .padding()
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: { onSave(image) }) {
                            Image(systemName: "square.and.arrow.down")
                                .offset(y: 40)
                                .font(.largeTitle)
                                .padding()
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
            }
        }
        .alert(isPresented: $viewModel.showSaveAlert) {
            Alert(
                title: Text("Saved"),
                message: Text("Your image has been saved to the photo library."),
                dismissButton: .default(Text("OK")) {
                    viewModel.showSaveAlert = false
                }
            )
        }
    }
}




#Preview {
    CameraView()
}
