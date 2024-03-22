//
//  SignUpView.swift
//  RealTime
//
//  Created by Marcus Grant on 11/20/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var errorMessage: String?
    @EnvironmentObject var authViewModel: AuthViewModel
    var isSecure: Bool = false
    
    var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Welcome").font(.title)
                        Text("Create account to continue!").font(.subheadline)
                            .foregroundStyle(.gray)
                        
                        CustomTextField(placeholder: Text("First Name"), text: $firstName)
                        CustomTextField(placeholder: Text("Last Name"), text: $lastName)
                        CustomTextField(placeholder: Text("Email"), text: $email)
                            .keyboardType(.emailAddress)
                        CustomTextField(placeholder: Text("Password"), text: $password, isSecure: true)
                        CustomTextField(placeholder: Text("Confirm Password"), text: $confirmPassword, isSecure: true)

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    VStack(spacing: 20) {
                        Button(action: signUpAction) {
                            Text("Create Account")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.teal)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                        }

                        HStack {
                            Rectangle().frame(width: 75, height: 1).foregroundColor(.gray)
                            Text("Or").padding(.horizontal)
                            Rectangle().frame(width: 75, height: 1).foregroundColor(.gray)
                        }

                        Button(action: googleSignUpAction) {
                            HStack {
                                Image("googlelogo") // Ensure this image is in your assets
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28)
                                Text("Continue With Google")
                            }
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: 350)
                            .background(Color.white)
                            .cornerRadius(8.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8.0)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }

                        HStack {
                            Text("I have an account,")
                            NavigationLink(destination: SignInView()) {
                                Text("Sign in").foregroundStyle(.teal)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
        }
    
    private func googleSignUpAction() {
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            authViewModel.signUpWithGoogle(presentingViewController: rootViewController)
        }
    }

        private func signUpAction() {
            // Add your sign-up logic here
            if password == confirmPassword {
                if password.count >= 6 {
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            print("Error occurred: \(error.localizedDescription)")
                            errorMessage = error.localizedDescription
                        } else {
                            print("User signed up successfully.")
                            errorMessage = nil
                            
                            // Create Firestore user document
                            if let authUser = authResult?.user {
                                let userData = [
                                    "id": authUser.uid,
                                    "email": email,
                                    "role": "user",  // Change this if you need different roles
                                    "name": firstName + " " + lastName
                                ]
                                
                                Firestore.firestore().collection("users").document(authUser.uid).setData(userData) { error in
                                    if let error = error {
                                        print("Error occurred: \(error.localizedDescription)")
                                    } else {
                                        print("User document created successfully.")
                                    }
                                }
                            }
                        }
                    }
                } else {
                    errorMessage = "Password should be at least 6 characters long."
                }
            } else {
                errorMessage = "Passwords do not match."
            }
        }
    }
    
    #Preview {
        SignUpView()
    }
    
