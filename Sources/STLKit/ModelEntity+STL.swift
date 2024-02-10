import Foundation
import RealityKit

public extension ModelEntity {
    /// Loads a single STL file from an URL asynconronously.
    static func loadSTL(contentsOf: URL, withUnits: STLUnits = STLUnits.meters) async throws -> ModelEntity {
        return try await STL.load(contentsOf: contentsOf, withUnits: withUnits)
    }
}
