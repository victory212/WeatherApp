# 🌦️ WeatherApp

A simple weather application built with **SwiftUI** using the **MVVM architecture**.  
This project demonstrates SOLID principles, dependency injection, and includes unit tests. 

--- 
## Minimum Requirements

- **Xcode 26**
- **iOS 26**
- Swift 5+ 

---

## 📱 Features
- Splash screen that navigates to the Home page  
- Enter a city name to fetch live weather data from [OpenWeather API](https://openweathermap.org/current)  
- Display weather description and temperature  
- Navigate to a detail screen with more info  
- Save a favorite city (prepopulates the text field on app launch)  
- Two screens minimum (Home + Weather Detail)  
- MVVM architecture applied  

---

## 🏗 Architecture
- **MVVM (Model-View-ViewModel)**  
- **Dependency Injection** for services and storage  
- **SOLID principles** followed:
- Single Responsibility: Each class has a single purpose (e.g., `WeatherService`, `HomeViewModel`)  
- Dependency Inversion: High-level modules depend on abstractions (`WeatherServiceProtocol`)  
- **Unit Tests** included for ViewModels and Services  

---

## 🛠 Tech Stack
- **Language**: Swift  
- **UI Framework**: SwiftUI  
- **Networking**: URLSession  
- **Persistence**: UserDefaults (for favorite city)  
- **Testing**: XCTest  

---

## 🚀 Running the App
1. Clone the repo:  
```bash
git clone https://github.com/victory212/WeatherApp.git
