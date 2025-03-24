//
//  AirportMapView - Lists and interacts with airports
//

import SwiftUI
import MapKit
import CoreLocation

struct AirportMapView: View {
    @StateObject var model = Model().load()
    @State private var position: MapCameraPosition = .automatic
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    @State private var selection: Airport? { didSet {
        withAnimation(.easeOut) {
            if selection != nil {
                columnVisibility = .all
                position = .region(selection!.coverage)
            } else {
                position = .region(model.coverage)
            }
        }
    } }

    var sidebar: some View {
        VStack {
            if selection != nil {
                AirportDetailPane(airport: selection!)
            } else {
                Text("Select an airport to see its routes")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
            .navigationSplitViewColumnWidth(min: 180, ideal: 210, max: 420)
        } detail: {
            Map(position: $position, interactionModes: [.pan, .zoom], selection: Binding(get: { selection }, set: { selection = $0 })) {
                if selection != nil {
                    ForEach(selection!.connections) { connection in
                        MapPolyline(coordinates: [
                            selection!.coordinate,
                            connection.destination.coordinate,
                        ], contourStyle: .geodesic)
                        .stroke(.secondary.opacity(0.5), lineWidth: 0.5 + Double(min(max(connection.flights.count, 1), 6)) * 0.25)
                    }
                }

                ForEach(model.airports) { airport in
                    Annotation(airport.name, coordinate: airport.coordinate) {
                        AirportMapItem(isMajor: (airport.flights.count >= 10), isSelected: (airport == selection))
                    }.tag(airport)
                }
            }
            .ignoresSafeArea()
            .mapControls {
                MapZoomStepper()
            }
            .mapStyle(.standard(
                elevation: .realistic,
                emphasis: .muted,
                pointsOfInterest: .including([
                    .museum, .castle, .fortress, .landmark, .nationalMonument,
                    .nationalPark, .amusementPark, .aquarium,
                    .beach, .park, .zoo, .hiking, .publicTransport]),
                showsTraffic: false
            ))
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
}

#Preview {
    AirportMapView()
}
