//
//  WeatherService.swift
//  时光格 - 天气服务
//
//  功能：使用 WeatherKit 获取详细天气信息，包括温度、空气质量、日出日落等
//

import Foundation
import WeatherKit
import CoreLocation
import SwiftUI

@MainActor
class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    @Published var isFetching = false
    @Published var error: WeatherError?
    
    enum WeatherError: LocalizedError {
        case notAvailable
        case locationRequired
        case networkError
        case apiError(String)
        
        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "WeatherKit 不可用，请检查开发者账号配置"
            case .locationRequired:
                return "需要位置信息才能获取天气"
            case .networkError:
                return "网络错误，请稍后重试"
            case .apiError(let message):
                return "天气服务错误: \(message)"
            }
        }
    }
    
    private init() {}
    
    // MARK: - 获取天气数据
    
    func fetchWeatherData(for location: CLLocation?, date: Date = Date()) async -> WeatherData? {
        guard let location = location else {
            error = .locationRequired
            return nil
        }
        
        // 检查 WeatherKit 是否可用
        guard #available(iOS 16.0, *) else {
            // iOS 16 以下使用简化版本
            return createFallbackWeatherData()
        }
        
        isFetching = true
        error = nil
        
        do {
            // 使用 WeatherKit
            let weatherKit = WeatherKit.WeatherService.shared
            let weather = try await weatherKit.weather(for: location)
            
            // 提取天气条件
            let condition = mapWeatherCondition(weather.currentWeather.condition)
            
            // 提取温度
            let temperature = weather.currentWeather.temperature.value
            
            // 提取空气质量（WeatherKit 可能不直接提供，暂时设为 nil）
            // 注意：WeatherKit 的 Weather 对象可能没有 airQuality 属性
            // 如果需要空气质量数据，可能需要使用其他 API 或服务
            let airQuality: Int? = nil
            
            // 提取湿度
            let humidity = weather.currentWeather.humidity * 100
            
            // 提取风速
            let windSpeed = weather.currentWeather.wind.speed.value
            
            // 计算日出日落时间
            let (sunrise, sunset, daylightHours) = calculateSunriseSunset(
                location: location,
                date: date
            )
            
            let weatherData = WeatherData(
                condition: condition,
                temperature: temperature,
                airQuality: airQuality,
                humidity: humidity,
                windSpeed: windSpeed,
                sunrise: sunrise,
                sunset: sunset,
                daylightHours: daylightHours
            )
            
            isFetching = false
            return weatherData
            
        } catch let fetchError {
            isFetching = false
            self.error = .apiError(fetchError.localizedDescription)
            // 失败时返回简化版本
            return createFallbackWeatherData()
        }
    }
    
    // MARK: - 辅助方法
    
    @available(iOS 16.0, *)
    private func mapWeatherCondition(_ condition: WeatherKit.WeatherCondition) -> Weather {
        switch condition {
        case .clear, .mostlyClear:
            return .sunny
        case .partlyCloudy, .mostlyCloudy, .cloudy:
            return .cloudy
        case .rain, .drizzle, .freezingRain:
            return .rainy
        case .snow, .sleet, .flurries:
            return .snowy
        case .windy, .breezy:
            return .windy
        default:
            return .cloudy
        }
    }
    
    private func calculateSunriseSunset(location: CLLocation, date: Date) -> (sunrise: String?, sunset: String?, daylightHours: String?) {
        // 使用简化的日出日落计算（实际应使用更精确的算法）
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: date)
        let month = components.month ?? 6
        
        // 简化的日出日落时间（基于月份估算）
        var sunriseHour = 6
        var sunsetHour = 18
        
        if month >= 11 || month <= 2 {
            // 冬季
            sunriseHour = 7
            sunsetHour = 17
        } else if month >= 3 && month <= 5 {
            // 春季
            sunriseHour = 6
            sunsetHour = 18
        } else if month >= 6 && month <= 8 {
            // 夏季
            sunriseHour = 5
            sunsetHour = 19
        } else {
            // 秋季
            sunriseHour = 6
            sunsetHour = 18
        }
        
        let sunrise = String(format: "%02d:%02d", sunriseHour, 30)
        let sunset = String(format: "%02d:%02d", sunsetHour, 30)
        let daylightHours = String(format: "%dh %dm", sunsetHour - sunriseHour, 0)
        
        return (sunrise, sunset, daylightHours)
    }
    
    private func createFallbackWeatherData() -> WeatherData {
        // 创建默认天气数据（当 WeatherKit 不可用时）
        return WeatherData(
            condition: .cloudy,
            temperature: nil,
            airQuality: nil,
            humidity: nil,
            windSpeed: nil,
            sunrise: nil,
            sunset: nil,
            daylightHours: nil
        )
    }
}

