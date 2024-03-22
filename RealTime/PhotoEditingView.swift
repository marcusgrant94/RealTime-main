//
//  PhotoEditingView.swift
//  RealTime
//
//  Created by Marcus Grant on 1/27/24.
//

import SwiftUI

struct PhotoEditingView: View {
    @State private var image: UIImage
    @State private var overlayText: String = ""
    @State private var textPosition: CGPoint = .zero
    @State private var isEditing: Bool = false

    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()

            if isEditing {
                TextField("Enter text", text: $overlayText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .position(x: textPosition.x, y: textPosition.y - 30) // Positioning above the finger

                Text(overlayText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    .position(textPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                self.textPosition = gesture.location
                            }
                    )
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button("Edit") {
                        self.isEditing = true
                        self.textPosition = CGPoint(x: image.size.width / 2, y: image.size.height / 2)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .padding()
                }
            }
        }
    }

    init(image: UIImage) {
        _image = State(initialValue: image)
    }
}
