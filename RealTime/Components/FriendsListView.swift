//
//  FriendsListView.swift
//  RealTime
//
//  Created by Marcus Grant on 1/23/24.
//

import SwiftUI

struct FriendsListView: View {
    var capturedPhoto: UIImage? // Make sure this is the actual captured photo
    @ObservedObject var usersViewModel: UsersViewModel
    var cameraViewModel: CameraViewModel
    @Binding var isPresented: Bool
    @State private var selectedFriends = Set<String>()

    var body: some View {
        VStack {
            NavigationView {
                List(usersViewModel.friends, id: \.id) { friend in
                    SelectableFriendRow(friend: friend, selectedFriends: $selectedFriends)
                }
                .navigationBarTitle("Send to", displayMode: .inline)
            }

            if !selectedFriends.isEmpty && capturedPhoto != nil {
                Button("Send") {
                    cameraViewModel.selectedFriendIds = selectedFriends
                    if let photo = capturedPhoto {
                        cameraViewModel.sendPhotoToSelectedFriends(photo)
                        cameraViewModel.onPhotoSent = {
                            self.isPresented = false
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            }
        }
    }
}



struct SelectableFriendRow: View {
    let friend: User
    @Binding var selectedFriends: Set<String>

    var body: some View {
        HStack {
            Circle()
                .stroke(selectedFriends.contains(friend.id) ? Color.blue : Color.gray, lineWidth: 2)
                .frame(width: 24, height: 24)
                .overlay(
                    selectedFriends.contains(friend.id) ? Circle().fill(Color.blue) : nil
                )
                .onTapGesture {
                    if selectedFriends.contains(friend.id) {
                        selectedFriends.remove(friend.id)
                    } else {
                        selectedFriends.insert(friend.id)
                    }
                }

            Text(friend.name)
        }
    }
}





//#Preview {
//    FriendsListView(usersViewModel: UsersViewModel(), cameraViewModel: CameraViewModel(), isPresented: <#Binding<Bool>#>)
//}
