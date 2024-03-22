//
//  CustomTextField.swift
//  RealTime
//
//  Created by Marcus Grant on 11/20/23.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder
                    .foregroundColor(.gray)
                    .padding(.leading, 12)
            }
            if isSecure {
                SecureField("", text: $text)
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal, 4)
            } else {
                TextField("", text: $text)
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal, 4)
            }
        }
        .frame(height: 50)
    }
}
