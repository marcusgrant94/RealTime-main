//
//  MessagesView.swift
//  RealTime
//
//  Created by Marcus Grant on 11/24/23.
//

import SwiftUI
import Firebase

struct MessagesView: View {
    @State private var showingConfirmationAlert = false

    var body: some View {
        VStack {
            Button {
                showingConfirmationAlert = true
            } label: {
                Text("Log Out")
                    .foregroundColor(.red)
            }
        }
        
        .alert(isPresented: $showingConfirmationAlert) {
            Alert(title: Text("Log Out"),
                  message: Text("Are you sure you want to log out?"),
                  primaryButton: .destructive(Text("Log Out"), action: {
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                    print("Error signing out: %@", signOutError)
                }
            }),
                  secondaryButton: .cancel())
        }
    }
}

#Preview {
    MessagesView()
}
