//
//  CapturedStoriesView.swift
//  RealTime
//
//  Created by Marcus Grant on 1/8/24.
//

import SwiftUI
import Firebase

struct CapturedStoriesView: View {
    @StateObject var viewModel = StoriesViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // Access the stories for the current user from the dictionary
                if let userId = authViewModel.currentUserId,
                   let userStories = viewModel.stories[userId] {
                    ForEach(userStories) { story in
                        StoryView(story: story)
                    }
                } else {
                    Text("No stories available")
                }
            }
            .onAppear {
                if let userId = authViewModel.currentUserId {
                    viewModel.fetchStories(userId: userId)
                }
            }
            .navigationTitle("My Stories")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StoryView: View {
    let story: Story
    @EnvironmentObject var viewModel: StoriesViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: story.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView() // Display during loading
                case .success(let image):
                    image.resizable() // Display the loaded image
                        .scaledToFit()
                case .failure:
                    Image(systemName: "photo") // Display if loading fails
                @unknown default:
                    EmptyView() // Fallback for future cases
                }
            }
            .frame(height: 200) // Set a fixed height for the image

            if authViewModel.currentUserId == story.userId {
                Button("Delete Story") {
                    viewModel.deleteStory(story.id) { success in
                        if success {
                            print("Story deleted")
                        } else {
                            print("Failed to delete story")
                        }
                    }
                }
                .foregroundStyle(.red)
                .padding()
            }
        }
    }
}

#Preview {
    CapturedStoriesView()
}
