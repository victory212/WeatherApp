//
//  Item.swift
//  WeatherApp
//
//  Created by Okoi Victory Ebri on 25/09/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
