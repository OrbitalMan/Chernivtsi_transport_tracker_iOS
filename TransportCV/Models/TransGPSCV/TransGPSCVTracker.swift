//
//  TransGPSCVTracker.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import CoreLocation

struct TransGPSCVTracker: Codable {
    
    let idBusTypes: Int?
    let routeId: Int
    let lat: Double
    let lng: Double
    let orientation: String?
    let speed: String?
    let gpstime: String?
    let busNumber: String
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/Kiev")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
}

extension TransGPSCVTracker: TrackerConvertible {
    
    func getVehicleType() -> VehicleType? {
        return VehicleType(transGPSIdBusTypes: idBusTypes)
    }
    
    func getProvider() -> Provider {
        return .transGPS(id: routeId)
    }
    
    func getCoordinate() -> Coordinate {
        return Coordinate(latitude: lat, longitude: lng)
    }
    
    func getCourse() -> Double {
        return Double(orientation ?? "0") ?? 0
    }
    
    func getSpeed() -> Double {
        return Double(speed ?? "0") ?? 0
    }
    
    func getTimestamp() -> Date {
        return Self.dateFormatter.date(from: gpstime ?? "") ?? Date(timeIntervalSince1970: 0)
    }
    
    func getBusNumber() -> Int {
        return busNumber.apiSafeIntValue ?? -1
    }
    
}

typealias TransGPSCVTrackerContainer = [String: Safe<TransGPSCVTracker>]
