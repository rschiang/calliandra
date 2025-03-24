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
                position = .region(findBound(for: selection!.connections.map(\.destination) + [selection!]))
            } else {
                position = .region(findBound(for: model.airports))
            }
        }
    } }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack {
                if selection != nil {
                    HStack {
                        Text(selection!.name)
                            .font(.title)
                        Spacer()
                        Text(selection!.id)
                            .font(.title2)
                            .monospaced()
                            .foregroundStyle(.secondary)
                    }.padding(.horizontal, 16)
                    Spacer()
                    List {
                        ForEach(selection!.connections) { connection in
                            VStackLayout(alignment: .leading) {
                                HStack {
                                    Text(connection.destination.name)
                                        .font(.headline)
                                    Spacer()
                                    Text(connection.destination.id)
                                        .monospaced()
                                        .foregroundStyle(.secondary)
                                }
                                HStackLayout(spacing: 4) {
                                    ForEach(connection.flights) { flight in
                                        Text(flight.departureTime)
                                            .fixedSize()
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Text("Select an airport to see its routes")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 210)
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
                    let isMajor = (airport.flights.count > 6)
                    let isSelected = (airport == selection)
                    Annotation(airport.name, coordinate: airport.coordinate) {
                        Image(systemName: "airplane.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(isSelected ? Color.white : Color.accentColor, isSelected ? Color.accentColor : Color.accentColor.opacity(0.25))
                            .imageScale((isMajor || isSelected) ? .large : .small)
                            .clipShape(Circle())
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
        longitudeDelta: (maxLng - minLng) * 1.2
    )

    return MKCoordinateRegion(center: center, span: span)
}

#Preview {
    AirportMapView()
}
