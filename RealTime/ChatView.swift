//
//  ChatView.swift
//  RealTime
//
//  Created by Marcus Grant on 1/18/24.
//

import SwiftUI
import Firebase

struct ChatView: View {
    @StateObject var messagesViewModel: MessagesViewModel
    @State private var messageText: String = ""
    var friend: User

    init(friend: User) {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        _messagesViewModel = StateObject(wrappedValue: MessagesViewModel(currentUserId: currentUserId, chatPartnerId: friend.id))
        self.friend = friend
    }

    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack {
                        ForEach(Array(messagesViewModel.messages.enumerated()), id: \.element.id) { index, message in
                            MessageView(message: message, currentUserId: friend.id)
                                .id(index) // Assigning a unique ID
                        }
                    }
                }
                .onChange(of: messagesViewModel.messages.count) { _ in
                    if let lastMessageIndex = messagesViewModel.messages.indices.last {
                        scrollView.scrollTo(lastMessageIndex, anchor: .bottom)
                    }
                }
            }

            MessageInputView(messageText: $messageText, sendMessage: { messageText in
                messagesViewModel.sendMessage(messageText)
                self.messageText = "" // Clear the input field after sending
            })
        }
        .navigationTitle(friend.name) // Optional: Show friend's name as title
    }
}




//#Preview {
//    ChatView()
//}
