import XCTest
import RealityKit
@testable import STLKit

final class STLKitTests: XCTestCase {
    func test_stlText() async throws {
        // given a text style STL file
        guard let resourceURL = Bundle.module.url(forResource: "300_polygon_sphere_100mm", withExtension: "STL") else {
            XCTFail();
            return;
        }
        // when it is loaded
        let model = try? await ModelEntity.loadSTL(contentsOf: resourceURL);
        XCTAssertNotNil(model);

    }
}
