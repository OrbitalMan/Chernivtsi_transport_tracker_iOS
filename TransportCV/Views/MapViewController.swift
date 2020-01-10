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
    
    /// The main view. Represents a map to pick a location on.
    let mapView = MKMapView()
    
    /// Requests the real location to get initial coordinate for user convenience.
    let locationManager = CLLocationManager()
    
    var trackers: [GenericTracker] = [] {
        didSet {
            updateAnnotations()
        }
    }
    
    // MARK: -
    
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
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        refresh()
        getLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let image: UIImage?
        let title: String
        if #available(iOS 13.0, *) {
            let checkedRoutes = Storage.checkedRoutes
            if checkedRoutes.contains(where: { !$0.value }) {
                if !checkedRoutes.contains(where: { $0.value }) {
                    image = UIImage(systemName: "xmark.rectangle")
                } else {
                    image = UIImage(systemName: "checkmark.rectangle")
                }
            } else {
                image = UIImage(systemName: "checkmark.rectangle.fill")
            }
            navigationItem.leftBarButtonItem?.image = image
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateAnnotations()
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
    
    func getTrackers() {
        trackers = []
        
        TransGPSCVAPI.getTrackers { [weak self] transGPSResult in
            switch transGPSResult {
            case let .success(transGPSTrackers):
                print("trans-gps trackers:", transGPSTrackers.count)
                let genericTrackers = transGPSTrackers.map { $0.asGenericTracker }
                self?.trackers.append(contentsOf: genericTrackers)
            case let .failure(error):
                print("trans-gps trackers error:", error)
            }
        }
        
        TransportCVAPI.getTrackers { [weak self] transportResult in
            switch transportResult {
            case let .success(transportTrackers):
                print("transport trackers:", transportTrackers.count)
                let genericTrackers = transportTrackers.map { $0.asGenericTracker }
                self?.trackers.append(contentsOf: genericTrackers)
            case let .failure(error):
                print("transport trackers error:", error)
            }
        }
    }
    
    func updateAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        let checkedRoutes = Storage.checkedRoutes
        for tracker in trackers {
            if let key = tracker.route?.key, checkedRoutes[key] == false {
                continue
            }
            let newPointer = MKPointAnnotation()
            newPointer.coordinate = tracker.location.coordinate
            newPointer.title = tracker.route?.key.title ?? tracker.title
            newPointer.subtitle = tracker.title
            mapView.addAnnotation(newPointer)
        }
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        
    }
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView: MKAnnotationView
        if #available(iOS 11.0, *) {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "id")
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
        }
        return annotationView
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
