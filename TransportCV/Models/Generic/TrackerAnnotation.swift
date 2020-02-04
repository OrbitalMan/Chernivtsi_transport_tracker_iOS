//
//  TrackerAnnotation.swift
//  TransportCV
//
//  Created by Stanislav on 11.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import MapKit

class TrackerAnnotation: MKPointAnnotation {
    
    dynamic var tracker: Tracker {
        didSet {
            update()
        }
    }
    
    @objc dynamic var location = CLLocation()
    
    init(tracker: Tracker) {
        self.tracker = tracker
        super.init()
        update()
    }
    
    func update() {
        location = tracker.location
        coordinate = location.coordinate
        title = tracker.route?.key.title ?? tracker.subtitle
        subtitle = tracker.subtitle
    }
    
}
