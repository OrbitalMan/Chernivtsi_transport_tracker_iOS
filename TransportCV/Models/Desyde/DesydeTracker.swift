//
//  DesydeTracker.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import CoreLocation

struct DesydeTracker: Codable {
    
    let tteId: Int?
    let routeId: Int?
    let latitude: Double
    let longitude: Double
    let angle: Double?
    let speed: Double?
    let datetime: String?
    let number: String
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/Kiev")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
}

extension DesydeTracker: TrackerConvertible {
    
    func getVehicleType() -> VehicleType? {
        return VehicleType(desydeTteId: tteId)
    }
    
    func getProvider() -> Provider {
        return .desyde(id: routeId)
    }
    
    func getCoordinate() -> Coordinate {
        return Coordinate(latitude: latitude, longitude: longitude)
    }
    
    func getCourse() -> Double {
        return angle ?? 0
    }
    
    func getSpeed() -> Double {
        return speed ?? 0
    }
    
    func getTimestamp() -> Date {
        return Self.dateFormatter.date(from: datetime ?? "") ?? Date(timeIntervalSince1970: 0)
    }
    
    func getBusNumber() -> Int {
        return number.apiSafeIntValue ?? -1
    }
    
}
