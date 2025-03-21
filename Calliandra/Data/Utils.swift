//
//  Utils - Specifying how to load data
//

import SwiftUI

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
