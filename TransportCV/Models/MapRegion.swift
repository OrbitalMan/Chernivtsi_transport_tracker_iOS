//
//  MapRegion.swift
//  TransportCV
//
//  Created by Stanislav on 20.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import MapKit

struct MapRegion: Codable {
    
    let centerLatitude: Double
    let centerLongitude: Double
    let spanLatitudeDelta: Double
    let spanLongitudeDelta: Double
    
    var mkRegion: MKCoordinateRegion {
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLatitude,
                                                                 longitude: centerLongitude),
                                  span: MKCoordinateSpan(latitudeDelta: spanLatitudeDelta,
                                                         longitudeDelta: spanLongitudeDelta))
    }
    
    init(mkRegion: MKCoordinateRegion) {
        centerLatitude = mkRegion.center.latitude
        centerLongitude = mkRegion.center.longitude
        spanLatitudeDelta = mkRegion.span.latitudeDelta
        spanLongitudeDelta = mkRegion.span.longitudeDelta
    }
    
}
