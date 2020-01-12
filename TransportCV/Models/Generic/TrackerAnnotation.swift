//
//  TrackerAnnotation.swift
//  TransportCV
//
//  Created by Stanislav on 11.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import MapKit

class TrackerAnnotation: MKPointAnnotation {
    
    dynamic var tracker: GenericTracker {
        didSet {
            update()
        }
    }
    
    @objc dynamic var location = CLLocation()
    
    init(tracker: GenericTracker) {
        self.tracker = tracker
        super.init()
        update()
    }
    
    func update() {
        location = tracker.location
        coordinate = location.coordinate
        title = tracker.route?.key.title ?? tracker.title
        subtitle = tracker.title
    }
    
}
