//
//  SignInView.swift
//  RealTime
//
//  Created by Marcus Grant on 11/20/23.
//

import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isShowingGoogleSignIn = false
    @EnvironmentObject var authViewModel: AuthViewModel
    var isSecure: Bool = false
    
    var body: some View {
            NavigationStack {
                VStack(alignment: .leading) {
    
                    VStack(alignment: .leading) {
                        Text("Welcome").font(.title)
                        Text("Sign in to continue!").font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    .padding(.leading, 21)
                    .padding(.bottom, 75)
                    
                    CustomTextField(placeholder: Text("Email"), text: $email)
                        .keyboardType(.emailAddress)
                        .offset(y: -20)
                        .padding()
                    
                    CustomTextField(placeholder: Text("Password"), text: $password, isSecure: true)
                        .offset(y: -20)
                        .padding(.horizontal)
                    NavigationLink(destination: ForgotPasswordView()) {
                        Text("Forgot Password?")
                            .foregroundStyle(.black)
                    }
                        .offset(x: 240, y: -23)
                    
                    Spacer()
                    
                }
                .padding(.top, 5)
                
                VStack {
                    Button {
                        authViewModel.signIn(email: email, password: password) { success, error in
                            if success {
                                errorMessage = nil
                            } else {
                                errorMessage = error ?? "Incorrect email or password"
                            }
                        }
                    } label: {
                        Text("Login")
                            .foregroundStyle(.white)
                            .frame(minWidth: 0, maxWidth: 330)
                            .padding()
                            .background(Color.teal)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .offset(y: -40)
                    HStack {
                        Rectangle()
                            .frame(width: 75, height: 1)
                            .foregroundColor(.gray)
                        Text("Or")
                        Rectangle()
                            .frame(width: 75, height: 1)
                            .foregroundColor(.gray)
                    }
                    .offset(y: -27)
                    Spacer()
                    Button {
                        // Contine with Google function here
                        } label: {
                            HStack {
                                Image("googlelogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28)
                                    .offset(x: -40)
                                Text("Continue With Google")
                            }
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(12)
                                .frame(maxWidth: 350)
                                .background(Color.white)
                                .cornerRadius(8.0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8.0)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        .offset(y: -120)
                    HStack {
                        Text("Im a new user,")
                        NavigationLink (destination: SignUpView()) {
                            Text("Sign Up")
                                .foregroundStyle(.teal)
                        }
                    }
                    .offset(y: -20)
                    Spacer()

                }
            }
        }
}

#Preview {
    SignInView()
}
