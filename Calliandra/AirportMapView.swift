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
                        .foregroundStyle(.primary)
                        .imageScale((isMajor || isSelected) ? .large : .small)
                        .symbolRenderingMode(isSelected ? .multicolor : .hierarchical)
                        .onTapGesture {
                            selection = airport
                            position = .item(MKMapItem(placemark: MKPlacemark(coordinate: airport.coordinate)), allowsAutomaticPitch: true)
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

#Preview {
    AirportMapView()
}
