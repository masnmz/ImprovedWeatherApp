//
//  ContentView.swift
//  ImprovedWeatherApp
//
//  Created by Mehmet Alp Sönmez on 18/12/2024.
//

import SwiftUI

struct ContentView: View {
    
    let blueSky = Color.init(red: 135/255, green: 206/255, blue: 235/255)
    
    let greySky = Color.init(red: 47/255, green: 79/255, blue: 79/255)
    
    @State var backgroundColour = Color.init(red: 135/255, green: 206/255, blue: 235/255)
    
    @State private var weatherData: WeatherData?
    @State private var results = [ForecastDay]()
    
    @State var weatherEmoji = "☀️"
    @State var currentTemp = 0
    @State var conditionText = "Slightly OverCast"
    @State var cityName = "Brighton"
    @State var loading = true
    
    var body: some View {
        VStack {
            Spacer()
            Text(cityName)
                .font(.system(size: 35))
                .bold()
            Text("\(Date().formatted(date:.complete, time: .omitted))")
                .font(.system(size: 18))
            Text(weatherEmoji)
                .font(.system(size: 180))
                .shadow(radius: 75)
            Text("\(currentTemp)°C")
                .font(.system(size: 70))
                .bold()
            Text(conditionText)
                .font(.system(size: 22))
                .bold()
            Spacer()
            Spacer()
            Spacer()
            
            List {
                if let forecast = weatherData?.forecast.forecastDay {
                    ForEach(forecast) { day in
                        HStack(alignment: .center, spacing: nil) {
                            Text(getShortDate(epoch: day.dateEpoch))
                                .frame(maxWidth: 50, alignment: .leading)
                                .bold()
                            Text("\(getWeatherEmoji(text: day.day.condition.text))")
                                .frame(maxWidth: 50, alignment: .leading)
                            Text("\(Int(day.day.avgTempC))°C")
                                .frame(maxWidth: 50, alignment: .leading)
                            Text("\(day.day.condition.text)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        
                        }
                        .listRowBackground(Color.white.blur(radius: 80))
                    }
                    
                }
                else {
                    Text("Loading forecast...")
                }
                    
            }
            .contentMargins(.vertical, 0)
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.dark)
            Spacer()
            Text("Data supplied by Weather API")
                .font(.system(size: 14))
        }
        .background(backgroundColour)
        .task {
            await fetchWeather()
        }
        
    }
    
    func fetchWeather() async {
        let urlString = "http://api.weatherapi.com/v1/forecast.json?key=0ae9d0abef264110ae9163743241812&q=Brighton&days=3&aqi=no&alerts=no"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        do {
            // Fetch data asynchronously
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Decode the weather data
            let decoder = JSONDecoder()
            let weatherResponse = try decoder.decode(WeatherData.self, from: data)
            
            // Update the UI on the main thread
            DispatchQueue.main.async {
                self.weatherData = weatherResponse
                self.results = weatherResponse.forecast.forecastDay // Update your forecast results
                if let firstDay = weatherResponse.forecast.forecastDay.first {
                    self.currentTemp = Int(firstDay.day.avgTempC)
                    self.conditionText = firstDay.day.condition.text
                    self.weatherEmoji = self.getWeatherEmoji(text: firstDay.day.condition.text)
                    self.backgroundColour = self.getBackgroundColour(text: firstDay.day.condition.text)
                    self.cityName = weatherResponse.location.name
                }
                self.loading = false
            }
        } catch {
            print("Error fetching weather data: \(error.localizedDescription)")
        }
    }
    
    func getWeatherEmoji(text: String) -> String {
        var weatherEmoji = "☀️"
        let conditionText = text.lowercased()
        
        if conditionText.contains("snow") || conditionText.contains("blizzard"){
            weatherEmoji = "🌨️"
        } else if conditionText.contains("rain") {
            weatherEmoji = "🌧️"
        } else if conditionText.contains("partly cloudy") {
            weatherEmoji = "⛅️"
        } else if conditionText.contains("cloudy") || conditionText.contains("overcast"){
            weatherEmoji = "☁️"
        } else if conditionText.contains("clear") || conditionText.contains("sunny"){
            weatherEmoji = "☀️"
        }
        return weatherEmoji
    }
    
    func getBackgroundColour(text: String) -> Color {
        print("Condition Text for Background Colour: \(text)")
        var backgroundColour = blueSky
        let conditionText = text.lowercased()
        
        if !(conditionText.contains("clear") || conditionText.contains("sunny")) {
            backgroundColour = greySky
        }
        
        return backgroundColour
    }
    
    func getShortDate(epoch: Int) -> String {
        return Date(timeIntervalSince1970: TimeInterval(epoch)).formatted(Date.FormatStyle().weekday(.abbreviated))
        
    }
}

#Preview {
    ContentView()
}
