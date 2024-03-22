//
//  ProfilePlaceholder.swift
//  RealTime
//
//  Created by Marcus Grant on 1/8/24.
//

import SwiftUI

struct ProfilePlaceholder: View {
    @EnvironmentObject var usersViewModel: UsersViewModel
    var body: some View {
        ZStack {
            if let initial = usersViewModel.currentUser?.name.first {
                Circle()
                    .fill(generateRandomColor())
                    .frame(width: 100, height: 100)
                Text(String(initial))
                    .foregroundColor(.white)
                    .font(.largeTitle)
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 100, height: 100)
            }
        }
    }
}

func generateRandomColor() -> Color {
    // Generates a random color
    Color(
        red: Double.random(in: 0...1),
        green: Double.random(in: 0...1),
        blue: Double.random(in: 0...1)
    )
}

#Preview {
    ProfilePlaceholder()
}
