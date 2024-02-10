import RealityKit
import SwiftUI

/// An incredibly simple view to test that we can load STL visually
struct STLView: View {
    let stlAtURL: URL
    var body: some View {
        RealityView { content in
            if let model = try? await STL.load(contentsOf: stlAtURL, withUnits: .millimeters, materials: [SimpleMaterial(color:.darkGray, isMetallic: false)]) {
                model.scale = SIMD3(0.5, 0.5, 0.5)
                content.add(model)
            }
        }
    }
}

#Preview("A Sphere") {
    STLView(stlAtURL: Bundle.module.url(forResource: "300_polygon_sphere_100mm", withExtension: "STL")!)
}
