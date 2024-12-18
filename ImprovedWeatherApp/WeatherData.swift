//
//  WeatherData.swift
//  ImprovedWeatherApp
//
//  Created by Mehmet Alp Sönmez on 18/12/2024.
//

import Foundation

struct WeatherData: Codable {
    var location: Location
    var forecast: Forecast
}

struct Location: Codable {
    var name: String
}

struct Forecast: Codable {
    var forecastDay: [ForecastDay]
    
    enum CodingKeys: String, CodingKey {
        case forecastDay = "forecastday"
    }
}

struct ForecastDay: Codable, Identifiable {
    var dateEpoch: Int
    var id: Int { dateEpoch }
    var day: Day
    
    enum CodingKeys: String, CodingKey {
        case dateEpoch = "date_epoch"
        case day
    }
}

struct Day: Codable {
    var avgTempC: Double
    var condition: Condition
    
    enum CodingKeys: String, CodingKey {
        case avgTempC = "avgtemp_c"
        case condition
    }
}

struct Condition: Codable {
    var text: String
    
}

