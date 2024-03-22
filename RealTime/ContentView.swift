//
//  ContentView.swift
//  RealTime
//
//  Created by Marcus Grant on 11/20/23.
//

import SwiftUI
import Firebase


struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        if authViewModel.isSignedIn == nil {
            // Show a loading view or simply an empty view
            // to handle the 'nil' case
            Image("LaunchPhoto2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
        } else if authViewModel.isSignedIn == true {
            // Your TabBar or main app interface
            TabBar()
        } else {
            // The sign-in or registration view
            SignInView().environmentObject(authViewModel)
        }
    }
}


#Preview {
    ContentView().environmentObject(AuthViewModel())
}
