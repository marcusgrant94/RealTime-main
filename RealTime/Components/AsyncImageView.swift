//
//  AsyncImageView.swift
//  RealTime
//
//  Created by Marcus Grant on 1/16/24.
//

import SwiftUI

struct AsyncImageView: View {
    @State private var image: UIImage?
    @State private var isLoading: Bool = false
    let url: String

    var body: some View {
        Group {
            if isLoading {
                ProgressView() // Shows a loading indicator while the image is loading
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                Image(systemName: "photo") // A placeholder image
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            loadImage()
        }
    }

    func loadImage() {
            guard let imageUrl = URL(string: url), image == nil else { return }
        print("Loading image from URL: \(url)")
            isLoading = true
            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                if let error = error {
                    print("Error loading image: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }

                if let data = data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = uiImage
                        self.isLoading = false
                    }
                } else {
                    print("Unable to load image from data.")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }.resume()
        }
}
