//
//  AirlineIcon - helper view to generate airline icon
//

import SwiftUI

struct AirlineIcon {

    @ViewBuilder
    static func create(forAirline: String) -> some View {
        switch forAirline {
        case "JAL":
            Image(systemName: "bird.circle")
                .foregroundStyle(.red)
        case "JAC", "JTA", "RAC":
            Image(systemName: "sun.horizon.circle")
                .foregroundStyle(.red)
        case "FDA":
            Image(systemName: "mountain.2.circle")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.orange, .red)
        case "TTW":
            Image(systemName: "pawprint.fill")
                .foregroundStyle(.orange)
        case "APJ":
            Image(systemName: "leaf.fill")
                .foregroundStyle(.purple)
        case "JJP":
            Image(systemName: "star.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.orange, .white.opacity(0.3))
        case "TWB":
            Image(systemName: "t.square.fill")
                .foregroundStyle(.red)
        case "JJA":
            Image(systemName: "j.square.fill")
                .foregroundStyle(.orange)
        case "MDA":
            Image(systemName: "bird")
                .foregroundStyle(.blue)
        case "UIA":
            Image(systemName: "staroflife.shield.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .green)
        case "DAC":
            Image(systemName: "seal.fill")
                .foregroundStyle(.orange)
        case "SJX":
            Image(systemName: "moon.stars.fill")
                .foregroundStyle(.brown)
        default:
            Image(systemName: "airplane.up.right")
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            AirlineIcon.create(forAirline: "JAL")
            AirlineIcon.create(forAirline: "JTA")
            AirlineIcon.create(forAirline: "FDA")
            AirlineIcon.create(forAirline: "TTW")
            AirlineIcon.create(forAirline: "APJ")
            AirlineIcon.create(forAirline: "JJP")
        }
        HStack(spacing: 16) {
            AirlineIcon.create(forAirline: "TWB")
            AirlineIcon.create(forAirline: "JJA")
            AirlineIcon.create(forAirline: "MDA")
            AirlineIcon.create(forAirline: "UIA")
            AirlineIcon.create(forAirline: "DAC")
            AirlineIcon.create(forAirline: "SJX")
        }
    }.padding(32)
}
