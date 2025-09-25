//
//  HomeView.swift
//  WeatherApp
//
//  Created by Okoi Victory Ebri on 25/09/2025.
//


import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var navigate = false
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Text("City")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    Spacer()
                }
                
                TextField("Enter city", text: $viewModel.city)
                    .padding()
                    .background(
                        // Glassy background
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.7), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                }
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                }
                
                Spacer()
                    .frame(height: 5)
                
                Button {
                    Task {
                        await viewModel.fetchWeather()
                        if viewModel.weather != nil { navigate = true }
                    }
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .buttonStyle(.glass)
                
            }
            .padding(16)
            .frame(maxHeight: .infinity)
            .background(
                Image(.lightWeather)
                    .resizable()
                    .scaledToFill()
            )
            .ignoresSafeArea()
            .navigationDestination(isPresented: $navigate, destination: {
                if let resp = viewModel.weather {
                    WeatherDetailView(viewModel: WeatherViewModel(response: resp))
                }
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save favorite") {
                        withAnimation {
                            viewModel.saveFavorite()
                        }
                    }
                    .buttonStyle(.automatic)
                }
            }
            .navigationTitle("Home")
        }
    }
}
