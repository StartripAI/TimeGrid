//
//  MetadataCollector.swift
//  时光格 - 元数据采集器
//
//  功能：统一管理所有元数据的自动采集
//

import Foundation
import CoreLocation
import SwiftUI

@MainActor
class MetadataCollector: ObservableObject {
    static let shared = MetadataCollector()
    
    private let locationService = LocationService.shared
    private let weatherService = WeatherService.shared
    
    @Published var isCollecting = false
    @Published var collectedMetadata: CollectedMetadata?
    
    struct CollectedMetadata {
        var timestamp: Date
        var location: LocationData?
        var weatherData: WeatherData?
        
        init(timestamp: Date = Date(), location: LocationData? = nil, weatherData: WeatherData? = nil) {
            self.timestamp = timestamp
            self.location = location
            self.weatherData = weatherData
        }
    }
    
    private init() {}
    
    // MARK: - 采集所有元数据
    
    func collectAllMetadata(for date: Date = Date(), completion: @escaping (CollectedMetadata) -> Void) {
        isCollecting = true
        
        let timestamp = Date() // 精确时间戳
        
        // 1. 先获取位置
        locationService.fetchCurrentLocation { [weak self] locationData in
            guard let self = self else { return }
            
            // 2. 如果有位置，获取天气
            if let location = locationData?.coordinate {
                let clLocation = CLLocation(
                    latitude: location.lat,
                    longitude: location.lon
                )
                
                Task {
                    let weatherData = await self.weatherService.fetchWeatherData(
                        for: clLocation,
                        date: date
                    )
                    
                    let metadata = CollectedMetadata(
                        timestamp: timestamp,
                        location: locationData,
                        weatherData: weatherData
                    )
                    
                    await MainActor.run {
                        self.collectedMetadata = metadata
                        self.isCollecting = false
                        completion(metadata)
                    }
                }
            } else {
                // 没有位置，只返回时间戳
                let metadata = CollectedMetadata(
                    timestamp: timestamp,
                    location: nil,
                    weatherData: nil
                )
                
                self.collectedMetadata = metadata
                self.isCollecting = false
                completion(metadata)
            }
        }
    }
    
    // MARK: - 快速采集（仅时间戳）
    
    func collectQuickMetadata() -> CollectedMetadata {
        return CollectedMetadata(timestamp: Date())
    }
}

