//
//  LocationManager.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.
//

import Foundation
import CoreLocation
import MapKit


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0689, longitude: -118.4452),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    }
}
