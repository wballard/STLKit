import Foundation
import RealityKit

public extension ModelEntity {
    /// Loads a single STL file from an URL asynconronously.
    public static func loadSTL(contentsOf: URL, withUnits: STLUnits = STLUnits.meters) async throws -> ModelEntity {
        throw STLError.urlNotFound
    }
}
