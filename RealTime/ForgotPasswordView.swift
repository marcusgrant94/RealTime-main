//
//  ForgotPasswordView.swift
//  RealTime
//
//  Created by Marcus Grant on 1/4/24.
//

import SwiftUI
import Firebase

struct ForgotPasswordView: View {
    @State private var resetEmail = ""
    @State private var isLoading = false
    @State private var isSent = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Text("Please Enter your regestered email below to recieve password reset instructions")
                    
                        .foregroundStyle(.gray)
                        .padding(.horizontal)
                    Spacer()
                    
                    CustomTextField(placeholder: Text("Email"), text: $resetEmail)
                    if let errorMessage = errorMessage {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                }

                    Button(action: {
                                    isLoading = true
                                    Auth.auth().sendPasswordReset(withEmail: self.resetEmail) { error in
                                        isLoading = false
                                        if let error = error {
                                            // An error happened.
                                            print(error.localizedDescription)
                                            errorMessage = error.localizedDescription
                                        } else {
                                            // Password reset email has been sent.
                                            print("Password reset email has been sent.")
                                            isSent = true
                                            errorMessage = nil
                                        }
                                    }
                                }) {
                        Text("Submit")
                                        .foregroundStyle(.white)
                                        .frame(minWidth: 0, maxWidth: 330)
                                        .padding()
                                        .background(Color.teal)
                                        .cornerRadius(10)
                                        .shadow(radius: 10)
                    }
                    .padding(.top)
                    .disabled(isLoading)
                    
                    if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                        .scaleEffect(1.5, anchor: .center)
                                }
                    
                    if isSent {
                                    Text("Password reset email has been sent.")
                                        .foregroundColor(.green)
                                        .padding(.top)
                                }
                    
                }
            }
            .navigationTitle("Forgot Password")
            
        }
    }
}

#Preview {
    ForgotPasswordView()
}
