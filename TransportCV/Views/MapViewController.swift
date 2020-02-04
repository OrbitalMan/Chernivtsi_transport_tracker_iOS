//
//  MapViewController.swift
//  TransportCV
//
//  Created by Stanislav on 25.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    static var shared: MapViewController? {
        return (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.viewControllers.first as? MapViewController
    }
    
    @IBOutlet weak var routesItem: UIBarButtonItem!
    @IBOutlet weak var refreshItem: UIBarButtonItem!
    @IBOutlet weak var settingsItem: UIBarButtonItem!
    
    /// The main view. Represents a map to pick a location on.
    let mapView = MKMapView()
    
    /// Requests the real location to get initial coordinate for user convenience.
    let locationManager = CLLocationManager()
    
    let trackerAnnotationReuseIdentifier = "trackerAnnotationReuseIdentifier"
    var trackers: [Tracker] = []
    var visibleTrackers: [Tracker] = []
    var annotations: [TrackerAnnotation] = []
    var autoUpdateTimer = Timer()
    
    // MARK: -
    
    deinit {
        autoUpdateTimer.invalidate()
    }
    
    /// Sets the `mapView`, text fields and navigation items up.
    override func loadView() {
        super.loadView()
        title = "Map"
        view = mapView
    }
    
    /// The `mapView` and `locationManager` setup.
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false // TODO: need to implement annotations couse adjustment for map rotation
        if let mapRegion = Storage.mapRegion {
            mapView.region = mapRegion.mkRegion
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        getLocation()
        if #available(iOS 13.0, *) {
            settingsItem.image = UIImage(systemName: "gear")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let imageName: String
        let image: UIImage?
        let title: String
        let checkedRoutes = Storage.checkedRoutes
        if checkedRoutes.contains(where: { !$0.value }) {
            if !checkedRoutes.contains(where: { $0.value }) {
                imageName = "xmark.rectangle"
                title = "❌"
            } else {
                imageName = "checkmark.rectangle"
                title = "❎"
            }
        } else {
            imageName = "checkmark.rectangle.fill"
            title = "✅"
        }
        if #available(iOS 13.0, *) {
            image = UIImage(systemName: imageName)
        } else {
            image = nil
        }
        routesItem.image = image
        routesItem.title = title
        startAutoUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateVisibleTrackers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        autoUpdateTimer.invalidate()
    }
    
    @IBAction func selectRoutes() {
        navigationController?.pushViewController(RoutesTableViewController(),
                                                 animated: true)
    }
    
    @IBAction func refresh() {
        if RouteStore.shared.routes.isEmpty {
            RouteStore.shared.updateRoutes()
        }
        getTrackers()
        if Storage.autoUpdateInterval == nil {
            autoUpdateTimer.invalidate()
        }
    }
    
    @IBAction func settings() {
        let settingsSheet = UIAlertController(title: "Auto-update trackers:",
                                              message: nil,
                                              preferredStyle: .actionSheet)
        
        let setInterval: (TimeInterval?) -> () = { [weak self] interval in
            Storage.autoUpdateInterval = interval
            self?.startAutoUpdate()
        }
        
        settingsSheet.addAction(UIAlertAction(title: "Every 5 seconds",
                                              style: .default,
                                              handler: { _ in setInterval(5) }))
        settingsSheet.addAction(UIAlertAction(title: "Every 10 seconds",
                                              style: .default,
                                              handler: { _ in setInterval(10) }))
        settingsSheet.addAction(UIAlertAction(title: "Every 15 seconds",
                                              style: .default,
                                              handler: { _ in setInterval(15) }))
        settingsSheet.addAction(UIAlertAction(title: "Manual",
                                              style: .cancel,
                                              handler: { _ in setInterval(nil) }))
        present(settingsSheet, animated: true, completion: nil)
    }
    
    // MARK: -
    
    /// Asks the `locationManager` to request initial location.
    /// Also does `requestWhenInUseAuthorization` if necessary.
    func getLocation() {
        // No need to ask a location in this case - it will default (or did) to `AppConfig.location.customCoordinate` (see the `viewDidLoad`)
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestLocation()
            }
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }
    
    /// Moves visible region of the `mapView` to given location.
    ///
    /// - Parameters:
    ///   - newCoordinate: The `CLLocationCoordinate2D` to move to.
    ///   - size: The span size in `CLLocationDegrees`. Will use the `mapView` span if `nil` passed.
    ///   - animated: Whether it will be animated transition.
    func updateLocation(newCoordinate: CLLocationCoordinate2D,
                        size: CLLocationDegrees? = nil,
                        animated: Bool) {
        let span: MKCoordinateSpan
        if let size = size {
            span = MKCoordinateSpan(latitudeDelta: size,
                                    longitudeDelta: size)
        } else {
            span = mapView.region.span
        }
        mapView.setRegion(MKCoordinateRegion(center: newCoordinate,
                                             span: span),
                          animated: animated)
    }
    
    var getTrackerTasks = 0
    
    func getTrackers() {
        guard getTrackerTasks < 1 else { return }
        getTrackerTasks += 1
        TransGPSCVAPI.getTrackers { [weak self] transGPSResult in
            self?.getTrackerTasks -= 1
            switch transGPSResult {
            case let .success(transGPSTrackers):
                print("trans-gps trackers:", transGPSTrackers.count)
                let genericTrackers = transGPSTrackers.map(Tracker.from)
                self?.updateTrackers(newTrackers: genericTrackers)
            case let .failure(error):
                print("trans-gps trackers error:", error)
            }
        }
        
        getTrackerTasks += 1
        TransportCVAPI.getTrackers { [weak self] transportResult in
            self?.getTrackerTasks -= 1
            switch transportResult {
            case let .success(transportTrackers):
                print("transport trackers:", transportTrackers.count)
                let genericTrackers = transportTrackers.map(Tracker.from)
                self?.updateTrackers(newTrackers: genericTrackers)
            case let .failure(error):
                print("transport trackers error:", error)
            }
        }
    }
    
    func updateTrackers(newTrackers: [Tracker]) {
        var obsoleteTrackers: [Tracker] = []
        var updatedTrackers: [Tracker] = []
        var addedTrackers: [Tracker] = []
        for tracker in trackers {
            var updated = false
            var mayBeObsolete = false
            for newTracker in newTrackers {
                if newTracker == tracker {
                    if !(newTracker === tracker) {
                        tracker.update(with: newTracker)
                    }
                    updatedTrackers.append(newTracker)
                    updated = true
                    break
                } else if tracker.routeProvider.mayBeObsolete(with: newTracker.routeProvider) {
                    mayBeObsolete = true
                }
            }
            if !updated, mayBeObsolete {
                obsoleteTrackers.append(tracker)
            }
        }
        trackers.removeAll { obsoleteTrackers.contains($0) }
        addedTrackers = newTrackers
        addedTrackers.removeAll { updatedTrackers.contains($0) }
        trackers.append(contentsOf: addedTrackers)
        updateVisibleTrackers()
    }
    
    func updateVisibleTrackers() {
        let checkedRoutes = Storage.checkedRoutes
        visibleTrackers = trackers.filter { tracker in
            if let key = tracker.route?.key, checkedRoutes[key] == false {
                return false
            }
            return true
        }
        updateAnnotations(newTrackers: visibleTrackers)
    }
    
    func updateAnnotations(newTrackers: [Tracker]) {
        var obsoleteAnnotations: [TrackerAnnotation] = []
        var updatedTrackers: [Tracker] = []
        for annotation in annotations {
            var updated = false
            for newTracker in newTrackers {
                if newTracker === annotation.tracker {
                    annotation.update()
                    updatedTrackers.append(newTracker)
                    updated = true
                    break
                }
            }
            if !updated {
                obsoleteAnnotations.append(annotation)
            }
        }
        for obsolete in obsoleteAnnotations {
            mapView.removeAnnotation(obsolete)
        }
        annotations.removeAll { obsoleteAnnotations.contains($0) }
        var addedTrackers = newTrackers
        addedTrackers.removeAll { updatedTrackers.contains($0) }
        let newAnnotations = addedTrackers.map(TrackerAnnotation.init)
        for new in newAnnotations {
            mapView.addAnnotation(new)
        }
        annotations.append(contentsOf: newAnnotations)
    }
    
    func startAutoUpdate() {
        refresh()
        autoUpdateTimer.invalidate()
        refreshItem.isEnabled = Storage.autoUpdateInterval == nil
        guard let autoUpdateInterval = Storage.autoUpdateInterval else { return }
        autoUpdateTimer = Timer(timeInterval: autoUpdateInterval,
                                 target: self,
                                 selector: #selector(refresh),
                                 userInfo: nil,
                                 repeats: true)
        RunLoop.current.add(autoUpdateTimer, forMode: .common)
        autoUpdateTimer.tolerance = 0.1
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        Storage.mapRegion = MapRegion(mkRegion: mapView.region)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let trackerAnnotation = annotation as? TrackerAnnotation else { return nil }
        if let dequeued = mapView.dequeueReusableAnnotationView(withIdentifier: trackerAnnotationReuseIdentifier) {
            dequeued.annotation = trackerAnnotation
            return dequeued
        }
        return TrackerAnnotationView(annotation: trackerAnnotation,
                                     reuseIdentifier: trackerAnnotationReuseIdentifier)
    }
    
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        getLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userCoordinate = locations.last?.coordinate {
            updateLocation(newCoordinate: userCoordinate, size: 0.05, animated: true)
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError: \(error.localizedDescription)")
    }
    
}
