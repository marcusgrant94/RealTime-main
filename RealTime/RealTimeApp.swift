//
//  RealTimeApp.swift
//  RealTime
//
//  Created by Marcus Grant on 11/20/23.
//

import SwiftUI
import Firebase

class NavigationState: ObservableObject {
    @Published var isTabBarHidden: Bool = false
}


@main
struct RealTimeApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var usersViewModel = UsersViewModel()
    @StateObject var navigationState = NavigationState()
    @StateObject private var storiesViewModel = StoriesViewModel()
    
    init() {
            FirebaseApp.configure()
        }

    var body: some Scene {
        WindowGroup {
//            SignUpView()
            ContentView().environmentObject(authViewModel).environmentObject(usersViewModel).environmentObject(navigationState).environmentObject(storiesViewModel)
//            SignUpView()
//            CameraView()
//            Home().environmentObject(authViewModel).environmentObject(UsersViewModel()).environmentObject(NavigationState())
//            ChatView()
        }
    }
}
