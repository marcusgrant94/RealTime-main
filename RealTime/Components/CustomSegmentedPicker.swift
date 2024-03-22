//
//  CustomSegmentedPicker.swift
//  RealTime
//
//  Created by Marcus Grant on 3/1/24.
//

import SwiftUI

struct CustomSegmentedPicker: View {
    @State private var selection: Int = 0
    
    var body: some View {
        HStack {
            Button(action: {
                self.selection = 0
            }) {
                Text("Friends")
                    .foregroundColor(self.selection == 0 ? .black : .gray)
                    .padding()
                    .background(self.selection == 0 ? Color.gray : Color.clear)
                    .cornerRadius(20)
            }
            .frame(maxWidth: .infinity)

            Button(action: {
                self.selection = 1
            }) {
                Text("Subscribed")
                    .foregroundColor(self.selection == 1 ? .black : .gray)
                    .padding()
                    .background(self.selection == 1 ? Color.gray : Color.clear)
                    .cornerRadius(20)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .background(Color.gray.opacity(0.2)) // Adjust the background color to match your UI
        .cornerRadius(25)
        .shadow(radius: 5) // Optional: add a shadow for depth, adjust as needed
    }
}

#Preview {
    CustomSegmentedPicker()
}
