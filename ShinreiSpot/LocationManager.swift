import CoreLocation
import Observation

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var location: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func distance(to spot: HauntedSpot) -> Double? {
        guard let loc = location else { return nil }
        let spotLoc = CLLocation(latitude: spot.latitude, longitude: spot.longitude)
        return loc.distance(from: spotLoc)
    }

    func distanceText(to spot: HauntedSpot) -> String {
        guard let d = distance(to: spot) else { return "-- km" }
        if d < 1000 {
            return String(format: "%.0f m", d)
        }
        return String(format: "%.1f km", d / 1000)
    }
}
