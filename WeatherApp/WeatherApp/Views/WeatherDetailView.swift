//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Okoi Victory Ebri on 25/09/2025.
//


import SwiftUI

struct WeatherDetailView: View {
    let viewModel: WeatherViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.cityName)
                .font(.largeTitle)
            Text(viewModel.description)
                .font(.title2)
            Text(viewModel.tempCelsius)
                .font(.title)
                .bold()
        }
        .padding()
        .navigationTitle("Weather Detail")
    }
}