//
//  StoryDetailView.swift
//  RealTime
//
//  Created by Marcus Grant on 1/15/24.
//

import SwiftUI

struct StoryDetailView: View {
    let story: Story
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
            VStack {
                if !story.imageUrl.isEmpty {
                    AsyncImageView(url: story.imageUrl)
                        .scaledToFit()
                        .frame(width: 300, height: 300) // Adjust as needed
                } else {
                    Text("No story available")
                }
        }
        .onAppear {
            print("StoryDetailView image URL: \(story.imageUrl)")
        }
    }
}



