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
                TextField("Enter city", text: $viewModel.city)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                }
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                }
                
                Button("Search") {
                    Task {
                        await viewModel.fetchWeather()
                        if viewModel.weather != nil { navigate = true }
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Save Favorite") {
                    viewModel.saveFavorite()
                }
            }
            .navigationDestination(isPresented: $navigate, destination: {
                if let resp = viewModel.weather {
                    WeatherDetailView(viewModel: WeatherViewModel(response: resp))
                }
            })
            .navigationTitle("Home")
        }
    }
}
