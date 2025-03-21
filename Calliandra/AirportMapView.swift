//
//  AirportMapView - Lists and interacts with airports
//

import SwiftUI
import MapKit
import CoreLocation

struct AirportMapView: View {
    @StateObject var model = Model().load()
    @State private var position: MapCameraPosition = .automatic
    @State private var selection: Airport?

    var body: some View {
        Map(position: $position, interactionModes: .all) {
            if selection != nil {
                ForEach(selection!.connections) { connection in
                    MapPolyline(coordinates: [
                        selection!.coordinate,
                        connection.coordinate
                    ], contourStyle: .geodesic)
                    .stroke(.secondary, lineWidth: 1.0)
                }
            }

            ForEach(model.airports) { airport in
                let isMajor = (airport.flights.count > 6)
                let isSelected = (airport == selection)
                Annotation(airport.name, coordinate: airport.coordinate) {
                    Image(systemName: "airplane.circle.fill")
                        .clipShape(Circle())
                        .foregroundStyle(.primary)
                        .imageScale((isMajor || isSelected) ? .large : .small)
                        .symbolRenderingMode(isSelected ? .multicolor : .hierarchical)
                        .onTapGesture {
                            selection = airport
                            withAnimation(.easeOut) {
                                position = .region(findBound(for: airport.connections + [airport]))
                            }
                        }
                }
            }
        }
        .ignoresSafeArea()
        .mapControls {
            MapZoomStepper()
        }
        .mapStyle(.standard(
            elevation: .realistic,
            emphasis: .muted,
            pointsOfInterest: .including([.museum, .castle, .fortress, .landmark, .nationalMonument, .nationalPark, .amusementPark, .aquarium, .beach, .park, .zoo, .hiking, .publicTransport]),
            showsTraffic: false
        ))
    }
}

func findBound(for airports: [Airport]) -> MKCoordinateRegion {
    var minLat = 90.0, minLng = 180.0, maxLat = 0.0, maxLng = 0.0

    for airport in airports {
        minLat = min(minLat, airport.latitude)
        minLng = min(minLng, airport.longitude)
        maxLat = max(maxLat, airport.latitude)
        maxLng = max(maxLng, airport.longitude)
    }

    let center = CLLocationCoordinate2D(
        latitude: (minLat + maxLat) / 2,
        longitude: (minLng + maxLng) / 2
    )

    let span = MKCoordinateSpan(
        latitudeDelta: (maxLat - minLat) * 1.2,
        longitudeDelta: (maxLng - minLng) * 1.1
    )

    return MKCoordinateRegion(center: center, span: span)
}

#Preview {
    AirportMapView()
}
