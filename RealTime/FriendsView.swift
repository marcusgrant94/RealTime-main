//
//  FriendsView.swift
//  RealTime
//
//  Created by Marcus Grant on 1/14/24.
//

import SwiftUI

struct FriendsView: View {
    let customColor = Color(red: 22 / 255.0, green: 29 / 255.0, blue: 35 / 255.0)
    @EnvironmentObject var usersViewModel: UsersViewModel
    @EnvironmentObject var navigationState: NavigationState

    init() {
        // Remove separators and set the background color of the List
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableView.appearance().separatorStyle = .none
    }

    var body: some View {
        ZStack {
            // Set the background color for the entire screen area
            customColor.edgesIgnoringSafeArea(.all)

            NavigationView {
                List(usersViewModel.friends, id: \.id) { friend in
                    HStack {
                        // Display friend's image
                        if let profileImageUrl = friend.profileImageURL, !profileImageUrl.isEmpty {
                            AsyncImageView(url: profileImageUrl) // Replace AsyncImageView with your actual image loading view
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text(friend.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        Spacer() // Pushes the icon to the end
                        
                        // Use NavigationLink to navigate to ChatView
                        NavigationLink(destination: ChatView(friend: friend)
                            .onAppear {
                                navigationState.isTabBarHidden = true
                            }
                            .onDisappear {
                                navigationState.isTabBarHidden = false
                            }
                        ) {
                            Image(systemName: "bubble.right")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.white)
                        }
                    }
                    .listRowBackground(customColor) // Set each row's background color
                }
                .listStyle(PlainListStyle()) // Removes additional padding and separators
                .refreshable {
                    refreshFriendsList()
                }
                .navigationTitle("Friends")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddFriendsView()) {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }
                .background(customColor) // Set the background color for the List area
            }
            .background(customColor) // Set the background color for the NavigationView area
        }
        .onAppear {
            usersViewModel.fetchFriendsForCurrentUser() {
                // Actions to perform after friends are fetched, if any.
            }
        }
    }
    
    private func refreshFriendsList() {
        usersViewModel.fetchFriendsForCurrentUser() {
            // Actions to perform after friends are fetched, if any.
        }
    }
}





#Preview {
    FriendsView()
}
