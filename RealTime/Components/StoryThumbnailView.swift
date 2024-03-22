//
//  StoryThumbnailView.swift
//  RealTime
//
//  Created by Marcus Grant on 1/27/24.
//

import SwiftUI

struct StoryThumbnailView: View {
    var friend: User
    var stories: [Story]
    
    
    var body: some View {
           VStack {
               if let imageUrl = stories.first?.imageUrl, !imageUrl.isEmpty {
                   AsyncImageView(url: imageUrl)
                       .frame(width: 60, height: 60)
                       .clipShape(Circle())
                       .overlay(Circle().stroke(Color.gray, lineWidth: 2))
               } else {
                   Image(systemName: "person.crop.circle.fill")
                       .resizable()
                       .scaledToFit()
                       .frame(width: 60, height: 60)
                       .clipShape(Circle())
                       .overlay(Circle().stroke(Color.gray, lineWidth: 2))
               }
               Text(friend.name)
                   .font(.caption)
                   .foregroundStyle(.white)
           }
       }
   }
