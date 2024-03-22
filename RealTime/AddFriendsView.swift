//
//  AddFriendsView.swift
//  RealTime
//
//  Created by Marcus Grant on 1/14/24.
//

import SwiftUI

struct AddFriendsView: View {
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var addedFriendIds = Set<String>() // Set to keep track of added friends
    @EnvironmentObject var usersViewModel: UsersViewModel

    var body: some View {
            VStack {
                SearchBar(text: $searchText, onSearchButtonClicked: search)
                List(searchResults, id: \.id) { user in
                    HStack {
                        Text(user.email)
                        Spacer()
                        if addedFriendIds.contains(user.id) {
                            Text("Friend Added!")
                                .foregroundColor(.green)
                        } else {
                            Button("Add Friend") {
                                if let currentUserID = usersViewModel.currentUser?.id {
                                    usersViewModel.addFriend(toUserID: currentUserID, friendID: user.id)
                                    addedFriendIds.insert(user.id)
                                }
                            }
                        }
                    }
                }
            }
        .navigationBarTitle("Add Friends")
        .onAppear {
            usersViewModel.fetchAllUsers()
        }
    }

    private func search() {
        // Perform the search
        searchResults = usersViewModel.users.filter { $0.email.lowercased().contains(searchText.lowercased()) }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var onSearchButtonClicked: () -> Void

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        var onSearchButtonClicked: () -> Void

        init(text: Binding<String>, onSearchButtonClicked: @escaping () -> Void) {
            _text = text
            self.onSearchButtonClicked = onSearchButtonClicked
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            onSearchButtonClicked()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, onSearchButtonClicked: onSearchButtonClicked)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}


#Preview {
    AddFriendsView()
}
