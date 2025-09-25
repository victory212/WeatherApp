//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Okoi Victory Ebri on 25/09/2025.
//

import Foundation

protocol WeatherServiceProtocol {
    func fetchWeather(for city: String) async throws -> WeatherResponse
}

final class WeatherService: WeatherServiceProtocol {
    private let apiKey = "6b42b072cccc099a8af9982fa5b40a57"

    func fetchWeather(for city: String) async throws -> WeatherResponse {
        guard var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather") else {
            throw URLError(.badURL)
        }
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        guard let url = components.url else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
}
