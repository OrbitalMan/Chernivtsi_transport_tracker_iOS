//
//  TrackerStore.swift
//  TransportCV
//
//  Created by Stanislav on 13.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

class TrackerStore {
    
    static let shared = TrackerStore()
    private init() { }
    
    private(set) var getTrackerTasks = 0
    private(set) var trackers: [Tracker] = []
    
    func getTrackers(onUpdated: @escaping () -> ()) {
        guard getTrackerTasks < 1 else { return }
        getTrackerTasks += 1
        TransGPSAPI.getTrackers { [weak self] transGPSResult in
            self?.getTrackerTasks -= 1
            switch transGPSResult {
            case let .success(transGPSTrackers):
                print("trans-gps trackers:", transGPSTrackers.count)
                self?.updateTrackers(with: transGPSTrackers)
                onUpdated()
            case let .failure(error):
                print("trans-gps trackers error:", error)
            }
        }
        
        getTrackerTasks += 1
        DesydeAPI.getTrackers { [weak self] desydeResult in
            self?.getTrackerTasks -= 1
            switch desydeResult {
            case let .success(desydeTrackers):
                print("desyde trackers:", desydeTrackers.count)
                self?.updateTrackers(with: desydeTrackers)
                onUpdated()
            case let .failure(error):
                print("desyde trackers error:", error)
            }
        }
    }
    
    private func updateTrackers(with convertibles: [TrackerConvertible]) {
        let newTrackers = convertibles.map(Tracker.from)
        trackers.update(newElements: newTrackers)
    }
    
}
