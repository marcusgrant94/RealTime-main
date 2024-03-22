//
//  AuthViewModel.swift
//  RealTime
//
//  Created by Marcus Grant on 12/22/23.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase
import FirebaseCore

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool? = nil

        var authStateDidChangeHandler: AuthStateDidChangeListenerHandle?

        init() {
            authStateDidChangeHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.isSignedIn = user != nil
            }
        }

        deinit {
            if let handler = authStateDidChangeHandler {
                Auth.auth().removeStateDidChangeListener(handler)
            }
        }
    
    var currentUserId: String? {
           return Auth.auth().currentUser?.uid
       }

    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
            if let error = error {
                print("Error fetching sign in methods: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }

            if let methods = signInMethods, methods.contains("google.com") {
                // This email is linked with Google
                completion(false, "Your account was used with Google to sign up. Please log in with Google.")
                return
            }

            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("Error occurred: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    
    func signInWithGoogle(presentingViewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Error: Missing client ID")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [unowned self] result, error in
            if let error = error {
                print("Sign in failed with error: \(error.localizedDescription)")
                showAlert(presentingViewController, title: "Sign In Failed", message: "Could not sign in. Please try again.")
                return
            }

            guard let user = result?.user,
                  let email = user.profile?.email,
                  let idToken = user.idToken?.tokenString
            else {
                print("Error: Missing user or token")
                showAlert(presentingViewController, title: "Sign In Failed", message: "Could not sign in. Please try again.")
                return
            }

            Auth.auth().fetchSignInMethods(forEmail: email) { existingMethods, error in
                guard let existingMethods = existingMethods else {
                    print("Error: Could not fetch sign-in methods")
                    self.showAlert(presentingViewController, title: "Sign In Failed", message: "No existing account in our records, please create an account")
                    return
                }

                if existingMethods.isEmpty {
                    // No existing account with this email
                    self.showAlert(presentingViewController, title: "Sign In Failed", message: "No existing account found for this email. Please create an account first.")
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                Auth.auth().signIn(with: credential) { result, error in
                    if let error = error {
                        print("Firebase sign in failed with error: \(error.localizedDescription)")
                        self.showAlert(presentingViewController, title: "Sign In Failed", message: "Could not sign in. Please try again.")
                        return
                    }

                    self.isSignedIn = true
                }
            }
        }
    }
    
    


    func showAlert(_ viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func signUpWithGoogle(presentingViewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Error Missing client ID")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [unowned self] result, error in
            if let error = error {
                print("Sign up failed with error: \(error.localizedDescription)")
                showAlert(presentingViewController, title: "Sign Up Failed", message: "Could not sign up. Please try again.")
                return
            }

            guard let user = result?.user,
                  let email = user.profile?.email,
                  let idToken = user.idToken?.tokenString,
                  let firstName = user.profile?.givenName, // First name
                  let lastName = user.profile?.familyName // Last name
            else {
                print("Error: Missing user or token")
                showAlert(presentingViewController, title: "Sign Up Failed", message: "Could not sign up. Please try again.")
                return
            }
            
            let name = "\(firstName) \(lastName)"

            // Check if the email already exists in the authentication system
            Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
                if let error = error {
                    print("Could not fetch sign in methods: \(error.localizedDescription)")
                    self.showAlert(presentingViewController, title: "Sign Up Failed", message: "Could not sign up. Please try again.")
                    return
                }

                if signInMethods?.isEmpty ?? true {
                    // No existing account, proceed with account creation
                    let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            print("Account creation failed with error: \(error.localizedDescription)")
                            self.showAlert(presentingViewController, title: "Sign Up Failed", message: "Could not create account. Please try again.")
                            return
                        }

                        // Get the newly created user's UID
                        guard let uid = authResult?.user.uid else {
                            print("Error getting UID")
                            return
                        }

                        // Reference to the users collection
                        let usersCollectionRef = Firestore.firestore().collection("users")

                        // Check if a document exists for this user
                        usersCollectionRef.document(uid).getDocument { document, error in
                            if let document = document, document.exists {
                                print("User already exists in Firestore")
                            } else {
                                // User does not exist, create a new document
                                usersCollectionRef.document(uid).setData([
                                    "id": uid, // Make sure to set the ID here
                                    "email": email,
                                    "name": name,
                                    "role": "user", // You can set a default role here
                                    // other user information you want to store
                                ]) { error in
                                    if let error = error {
                                        print("Error writing document: \(error.localizedDescription)")
                                    } else {
                                        print("Document successfully written!")
                                        // Perform additional actions once the user is signed up
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.showAlert(presentingViewController, title: "Sign Up Failed", message: "An account with this email already exists. Please sign in instead.")
                }
            }
        }
    }

}
