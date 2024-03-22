//
//  MessagesListView.swift
//  RealTime
//
//  Created by Marcus Grant on 1/17/24.
//

import SwiftUI
import Firebase

struct MessagesListView: View {
    @ObservedObject var messagesViewModel: MessagesViewModel // ViewModel that contains message data

    var body: some View {
        ScrollView {
            VStack {
                ForEach(messagesViewModel.messages) { message in
                    MessageView(message: message, currentUserId: Auth.auth().currentUser?.uid ?? "")
                }
            }
        }
    }
}




struct MessageInputView: View {
    @Binding var messageText: String
    var sendMessage: (String) -> Void

    var body: some View {
        HStack {
            TextField("Type a message", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Send") {
                sendMessage(messageText)
                messageText = "" // Clear the text field
            }
        }
        .padding()
    }
}
