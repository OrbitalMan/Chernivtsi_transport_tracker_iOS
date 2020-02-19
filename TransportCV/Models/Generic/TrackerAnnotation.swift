//
//  TrackerAnnotation.swift
//  TransportCV
//
//  Created by Stanislav on 11.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import MapKit

protocol TrackerAnnotationConvertible {
    func getAnnotation(updating annotations: [TrackerAnnotation]?) -> TrackerAnnotation
}

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
        title = tracker.title
        subtitle = tracker.subtitle
    }
    
}

extension TrackerAnnotation: Updatable {
    
    static func == (lhs: TrackerAnnotation,
                    rhs: TrackerAnnotation) -> Bool {
        return lhs.tracker == rhs.tracker
    }
    
    func update(with new: TrackerAnnotation) {
        tracker.update(with: new.tracker)
        update()
    }
    
    func mayBeObsolete(with another: TrackerAnnotation) -> Bool {
        return true
    }
    
}
