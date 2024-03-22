//
//  MessagesViewModel.swift
//  RealTime
//
//  Created by Marcus Grant on 1/18/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI

class MessagesViewModel: ObservableObject {
    @Published var messages: [Message] = []
    
    private var db = Firestore.firestore()
    private var currentUserId: String // Current user's ID
    private var chatPartnerId: String // Chat partner's ID

    init(currentUserId: String, chatPartnerId: String) {
        self.currentUserId = currentUserId
        self.chatPartnerId = chatPartnerId
        fetchMessages()
    }
    
    func fetchMessages() {
        db.collection("messages")
            .whereField("senderId", in: [currentUserId, chatPartnerId])
            .whereField("recipientId", in: [currentUserId, chatPartnerId])
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.messages = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Message.self)
                }
            }
    }
    
    func sendMessage(_ messageContent: String) {
        let newMessage = Message(
            senderId: currentUserId,
            recipientId: chatPartnerId,
            text: messageContent,
            imageURL: nil,
            timestamp: Timestamp()
        )
        
        db.collection("messages").addDocument(data: [
            "senderId": newMessage.senderId,
            "recipientId": newMessage.recipientId,
            "text": newMessage.text,
            "imageURL": newMessage.imageURL as Any,
            "timestamp": newMessage.timestamp
        ]) { error in
            if let error = error {
                print("Error sending message: \(error)")
            }
        }
    }

}



struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    var senderId: String
    var recipientId: String
    var text: String
    var imageURL: String?
    var timestamp: Timestamp
}

