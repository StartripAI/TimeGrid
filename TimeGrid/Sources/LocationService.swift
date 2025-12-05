//
//  LocationService.swift
//  时光格 - 位置服务
//
//  功能：自动采集位置信息，支持逆地理编码
//

import Foundation
import CoreLocation
import SwiftUI

@MainActor
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: LocationData?
    @Published var isFetching = false
    @Published var error: LocationError?
    
    enum LocationError: LocalizedError {
        case notAuthorized
        case locationUnavailable
        case geocodingFailed
        case networkError
        
        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "需要位置权限才能自动记录地点"
            case .locationUnavailable:
                return "无法获取当前位置"
            case .geocodingFailed:
                return "无法解析地址"
            case .networkError:
                return "网络错误，请稍后重试"
            }
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - 请求权限
    
    func requestPermission() {
        guard authorizationStatus == .notDetermined else { return }
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - 获取当前位置
    
    func fetchCurrentLocation(completion: @escaping (LocationData?) -> Void) {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            error = .notAuthorized
            completion(nil)
            return
        }
        
        isFetching = true
        error = nil
        
        locationManager.requestLocation()
        
        // 使用临时存储回调
        locationCompletion = completion
    }
    
    private var locationCompletion: ((LocationData?) -> Void)?
    
    // MARK: - 逆地理编码
    
    private func reverseGeocode(location: CLLocation, completion: @escaping (LocationData?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("逆地理编码错误: \(error.localizedDescription)")
                // 即使编码失败，也返回坐标信息
                let locationData = LocationData(
                    address: nil,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    placeName: nil
                )
                completion(locationData)
                return
            }
            
            guard let placemark = placemarks?.first else {
                let locationData = LocationData(
                    address: nil,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    placeName: nil
                )
                completion(locationData)
                return
            }
            
            // 构建地址字符串
            var addressComponents: [String] = []
            if let locality = placemark.locality {
                addressComponents.append(locality)
            }
            if let subLocality = placemark.subLocality {
                addressComponents.append(subLocality)
            }
            if let thoroughfare = placemark.thoroughfare {
                addressComponents.append(thoroughfare)
            }
            
            let address = addressComponents.isEmpty ? nil : addressComponents.joined(separator: "")
            let placeName = placemark.name ?? placemark.locality
            
            let locationData = LocationData(
                address: address,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                placeName: placeName
            )
            
            completion(locationData)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        Task { @MainActor in
            self.isFetching = false
            
            // 逆地理编码
            self.reverseGeocode(location: location) { locationData in
                Task { @MainActor in
                    self.currentLocation = locationData
                    self.locationCompletion?(locationData)
                    self.locationCompletion = nil
                }
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isFetching = false
            self.error = .locationUnavailable
            self.locationCompletion?(nil)
            self.locationCompletion = nil
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}

