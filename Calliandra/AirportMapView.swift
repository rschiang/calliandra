//
//  AirportMapView - Lists and interacts with airports
//

import SwiftUI
import MapKit
import CoreLocation

struct AirportMapView: View {
    @StateObject var model = Model()
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedAirport: Airport?

    var body: some View {
        Map(position: $position, interactionModes: .all) {
            ForEach(model.airports) { airport in
                let isMajor = (model.flightsByOrigin[airport.id]?.count ?? 0 > 6)
                let isSelected = (selectedAirport == airport)
                Annotation(airport.name, coordinate: airport.coordinate) {
                    Image(systemName: "airplane.circle.fill")
                        .foregroundStyle(.primary)
                        .imageScale((isMajor || isSelected) ? .large : .small)
                        .symbolRenderingMode(isSelected ? .multicolor : .hierarchical)
                        .onTapGesture {
                            selectedAirport = airport
                        }
                }
            }
        }
    }
}

#Preview {
    AirportMapView()
}
