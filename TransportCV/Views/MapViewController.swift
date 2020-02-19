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
    
    @IBOutlet weak var routesItem: UIBarButtonItem!
    @IBOutlet weak var refreshItem: UIBarButtonItem!
    @IBOutlet weak var settingsItem: UIBarButtonItem!
    
    /// The main view. Represents a map to pick a location on.
    let mapView = MKMapView()
    
    /// Requests the real location to get initial coordinate for user convenience.
    let locationManager = CLLocationManager()
    
    let trackerAnnotationReuseIdentifier = "trackerAnnotationReuseIdentifier"
    
    var visibleTrackers: [Tracker] {
        let checkedRoutes = Storage.checkedRoutes
        return Tracker.store.trackers.filter { tracker in
            return checkedRoutes[tracker.routeKey] != false
        }
    }
    
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
        mapView.isRotateEnabled = false // TODO: need to implement annotations course adjustment for map rotation
        mapView.showsUserLocation = true
        if let mapRegion = Storage.mapRegion {
            mapView.region = mapRegion.mkRegion
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        getLocation()
        if #available(iOS 13.0, *) {
            settingsItem.image = UIImage(systemName: "gear")
        }
        refresh()
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
        if Route.store.routes.isEmpty {
            Route.store.updateRoutes { [weak self] in
                self?.updateVisibleTrackers()
            }
        }
        Tracker.store.getTrackers { [weak self] in
            self?.updateVisibleTrackers()
        }
        if Storage.autoUpdateInterval == 0 {
            autoUpdateTimer.invalidate()
        }
    }
    
    @IBAction func settings() {
        let currentInterval = Storage.autoUpdateInterval
        let intervalDescription: String
        if currentInterval == 0 {
            intervalDescription = "Manual"
        } else {
            intervalDescription = "Every \(Int(currentInterval)) seconds"
        }
        let title = "Auto-update trackers: \(intervalDescription)"
        let settingsSheet = UIAlertController(title: title,
                                              message: nil,
                                              preferredStyle: .actionSheet)
        
        let setInterval: (TimeInterval) -> () = { [weak self] interval in
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
                                              handler: { _ in setInterval(0) }))
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
    
    func updateVisibleTrackers() {
        updateAnnotations(with: visibleTrackers)
    }
    
    func updateAnnotations(with convertibles: [TrackerAnnotationConvertible]) {
        let previousAnnotationsCount = annotations.count
        let newAnnotations = convertibles.map { $0.getAnnotation(updating: annotations) }
        annotations.update(newElements: newAnnotations,
                           onRemoving: mapView.removeAnnotation,
                           onAdding: mapView.addAnnotation)
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .notDetermined, .denied, .restricted:
            if previousAnnotationsCount < annotations.count {
                mapView.showAnnotations(mapView.annotations, animated: true)
            }
        @unknown default:
            break
        }
    }
    
    func startAutoUpdate() {
        autoUpdateTimer.invalidate()
        refreshItem.isEnabled = Storage.autoUpdateInterval == 0
        let autoUpdateInterval = Storage.autoUpdateInterval
        if autoUpdateInterval == 0 { return }
        refresh()
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
            updateLocation(newCoordinate: userCoordinate, size: 0.03, animated: true)
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError: \(error.localizedDescription)")
    }
    
}
