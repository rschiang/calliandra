//
//  AirportMapView - Lists and interacts with airports
//

import SwiftUI
import MapKit
import CoreLocation

struct AirportMapView: View {
    @StateObject var model = Model()
    @State private var position: MapCameraPosition = .automatic
    @State private var selection: Int?

    var body: some View {
        Map(position: $position, interactionModes: .all) {
            ForEach(0..<model.airports.count) { i in
                let airport = model.airports[i]
                let isMajor = (model.flightsByOrigin[airport.id]?.count ?? 0 > 6)
                let isSelected = (i == selection)
                Annotation(airport.name, coordinate: airport.coordinate) {
                    Image(systemName: "airplane.circle.fill")
                        .foregroundStyle(.primary)
                        .imageScale((isMajor || isSelected) ? .large : .small)
                        .symbolRenderingMode(isSelected ? .multicolor : .hierarchical)
                        .onTapGesture {
                            selection = i
                            position = .item(MKMapItem(placemark: MKPlacemark(coordinate: airport.coordinate)), allowsAutomaticPitch: true)
                        }
                }
            }
        }
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
