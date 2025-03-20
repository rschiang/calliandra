//
//  AirportMapView - Lists and interacts with airports
//

import SwiftUI
import MapKit
import CoreLocation

struct AirportMapView: View {
    @State private var position: MapCameraPosition = .automatic
    @Binding var airports: [Airport]
    @State private var selectedAirport: Airport?

    var body: some View {
        Map(position: $position, interactionModes: .all) {
            ForEach(airports) { airport in
                Annotation(airport.name, coordinate: airport.coordinate) {
                    Image(systemName: "airplane.circle.fill")
                        .foregroundStyle(.primary)
                        .imageScale(.large)
                        .symbolRenderingMode(selectedAirport == airport ? .multicolor : .hierarchical)
                        .onTapGesture {
                            selectedAirport = airport
                        }
                }
            }
        }
    }
}

#Preview {
    AirportMapView(airports: .constant([
        Airport(id: "TPE", name: "台北", latitude: 25.07, longitude: 121.55, country: "TW"),
        Airport(id: "KHH", name: "高雄", latitude: 22.57, longitude: 120.34, country: "TW"),
        Airport(id: "HND", name: "東京羽田", latitude: 35.55, longitude: 139.77, country: "JP"),
        Airport(id: "KIX", name: "大阪関西", latitude: 34.44, longitude: 135.22, country: "JP"),
        Airport(id: "FUK", name: "福岡", latitude: 33.59, longitude: 130.44, country: "JP"),
        Airport(id: "SDJ", name: "仙台", latitude: 38.16, longitude: 140.95, country: "JP"),
        Airport(id: "CTS", name: "札幌", latitude: 42.79, longitude: 141.67, country: "JP"),
        Airport(id: "ICN", name: "首爾仁川", latitude: 37.48, longitude: 126.46, country: "KR"),
        Airport(id: "PUS", name: "釜山", latitude: 35.16, longitude: 128.92, country: "KR"),
    ]))
}
