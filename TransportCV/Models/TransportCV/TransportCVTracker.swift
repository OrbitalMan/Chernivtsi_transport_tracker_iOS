//
//  TransportCVTracker.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import CoreLocation

struct TransportCVTracker: Codable {
    
    let routeId: Int?
    let latitude: Double
    let longitude: Double
    let angle: Double
    let speed: Double
    let datetime: String
    let number: String
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/Kiev")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
}

extension TransportCVTracker: TrackerConvertible {
    
    func getVehicleType() -> VehicleType {
        return RouteStore.shared.findRoute(provider: getProvider())?.key.type ?? .trolley
    }
    
    func getProvider() -> Provider {
        return .desyde(id: routeId)
    }
    
    func getCoordinate() -> Coordinate {
        return Coordinate(latitude: latitude, longitude: longitude)
    }
    
    func getCourse() -> Double {
        return angle
    }
    
    func getSpeed() -> Double {
        return speed
    }
    
    func getTimestamp() -> Date {
        return Self.dateFormatter.date(from: datetime) ?? Date(timeIntervalSince1970: 0)
    }
    
    func getBusNumber() -> Int {
        return number.apiSafeIntValue ?? -1
    }
    
}
