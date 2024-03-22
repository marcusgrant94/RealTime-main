//
//  VideoPlayerView.swift
//  RealTime
//
//  Created by Marcus Grant on 11/22/23.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    var videoURL: URL
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            VideoPlayer(player: AVPlayer(url: videoURL))
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .padding()
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
