//
//  SplashView.swift
//  WeatherApp
//
//  Created by Okoi Victory Ebri on 25/09/2025.
//


import SwiftUI

struct SplashView<Content: View>: View {
    @State private var isActive = false
    let content: () -> Content

    var body: some View {
        Group {
            if isActive {
                content()
            } else {
                VStack {
                    Text("🌤 WeatherApp")
                        .font(.largeTitle)
                        .bold()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}