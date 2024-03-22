//
//  TabBar.swift
//  RealTime
//
//  Created by Marcus Grant on 11/24/23.
//

import SwiftUI

struct TabBar: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            CameraView()
                .tabItem {
                    Label("Home", systemImage: "camera")
                }
            
            
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.3")
                }
        }
        .accentColor(Color.gray)
    }
}

#Preview {
    TabBar()
}
