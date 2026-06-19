//
//  Utils - Specifying how to load data
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation

func loadFile<T: Decodable>(fileName: String) -> [T] {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        fatalError("Cannot find JSON resource named \(fileName).json")
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([T].self, from: data)
    } catch {
        fatalError("Error loading \(fileName): \(error)")
    }
}

func findBound(from: Airport, for airports: [Airport]) -> MKCoordinateRegion {
    let initial = from.coordinate
    var minLat = initial.latitude, maxLat = initial.latitude
    var minLon = initial.longitude, maxLon = initial.longitude

    for airport in airports {
        minLat = min(minLat, airport.latitude)
        minLon = min(minLon, airport.longitude)
        maxLat = max(maxLat, airport.latitude)
        maxLon = max(maxLon, airport.longitude)
    }

    let center = CLLocationCoordinate2D(
        latitude: (minLat + maxLat) / 2,
        longitude: (minLon + maxLon) / 2
    )

    let span = MKCoordinateSpan(
        latitudeDelta: (maxLat - minLat) * 1.2,
        longitudeDelta: (maxLon - minLon) * 1.2
    )

    return MKCoordinateRegion(center: center, span: span)
}

func greatCircleMiles(from origin: Airport, to destination: Airport) -> Int {
    let originLocation = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
    let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
    let meters = originLocation.distance(from: destinationLocation)
    return Int((meters / 1609.344).rounded())
}

func flightDuration(from departureTime: String, to arrivalTime: String) -> String? {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.locale = Locale(identifier: "en_US_POSIX")

    guard let departure = formatter.date(from: departureTime),
          var arrival = formatter.date(from: arrivalTime) else {
        return nil
    }

    if arrival < departure {
        arrival = Calendar.current.date(byAdding: .day, value: 1, to: arrival) ?? arrival
    }

    let minutes = Int(arrival.timeIntervalSince(departure) / 60)
    let hours = minutes / 60
    let remainingMinutes = minutes % 60

    if hours == 0 {
        return "\(remainingMinutes)m"
    }
    return "\(hours)h \(remainingMinutes)m"
}
