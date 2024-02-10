import Foundation
import RealityKit
import RegexBuilder

/// Figure out the specific STL subformat
enum STLFileType {
    case unknown
    case text
    case binary
}

/// Not a lot of states, but a state machine for parsing.
enum STLTextState {
    case start
    case solid
    case facet
    case loop
    case end
}

/// Text file format state machine driven regex parser
/// It would be fairly cool to have Parsec in Swift rather than this gobbly 🦃
class STLTextParser {
    let parseVertex: Regex<(Substring, Float, Float, Float)>
    let parseFacet: Regex<(Substring, Float, Float, Float)>
    let parseEndFacet: Regex<Substring>
    let parseLoop: Regex<Substring>
    let parseEndLoop: Regex<Substring>
    let parseSolid: Regex<(Substring, String)>
    let parseEndSolid: Regex<(Substring, String)>

    var state = STLTextState.start
    var name = ""
    var vertexBuffer = [SIMD3<Float>]()
    var normalsBuffer = [SIMD3<Float>]()
    var indexBuffer = [UInt32]()

    init() throws {
        let vectorComponent = Capture {
            Optionally(CharacterClass(.anyOf("+-")))
            ZeroOrMore(.digit)
            Optionally(CharacterClass(.anyOf(".")))
            ZeroOrMore(.digit)
            Optionally(CharacterClass(.anyOf("eE")))
            Optionally(CharacterClass(.anyOf("+-")))
            ZeroOrMore(.digit)
        } transform: {
            Float(String($0))!
        }
        self.parseVertex = Regex {
            ZeroOrMore(.whitespace)
            "vertex"
            OneOrMore(.whitespace)
            vectorComponent
            OneOrMore(.whitespace)
            vectorComponent
            OneOrMore(.whitespace)
            vectorComponent
            ZeroOrMore(.whitespace)
            Anchor.endOfLine
        }
        self.parseFacet = Regex {
            ZeroOrMore(.whitespace)
            "facet"
            OneOrMore(.whitespace)
            "normal"
            OneOrMore(.whitespace)
            vectorComponent
            OneOrMore(.whitespace)
            vectorComponent
            OneOrMore(.whitespace)
            vectorComponent
            ZeroOrMore(.whitespace)
            Anchor.endOfLine
        }
        self.parseEndFacet = Regex {
            ZeroOrMore(.whitespace)
            "endfacet"
            ZeroOrMore(.whitespace)
        }
        self.parseLoop = Regex {
            ZeroOrMore(.whitespace)
            "outer"
            ZeroOrMore(.whitespace)
            "loop"
            ZeroOrMore(.whitespace)
        }
        self.parseEndLoop = Regex {
            ZeroOrMore(.whitespace)
            "endloop"
            ZeroOrMore(.whitespace)
        }
        self.parseSolid = Regex {
            "solid"
            OneOrMore(.whitespace)
            Capture { .whitespace.inverted } transform: {
                String($0)
            }
            ZeroOrMore(.whitespace)
        }
        self.parseEndSolid = Regex {
            "endsolid"
            OneOrMore(.whitespace)
            Capture { .whitespace.inverted } transform: {
                String($0)
            }
            ZeroOrMore(.whitespace)
        }
    }

    func process(_ line: String) throws {
        switch self.state {
        case .start:
            if let match = try? self.parseSolid.firstMatch(in: line) {
                self.name = match.output.1
                self.state = .solid
            } else {
                throw STLError.invalidSTLFormat(line)
            }
        case .solid:
            if (try? self.parseEndSolid.firstMatch(in: line)) != nil {
                self.state = .end
            } else if let facet = (try? self.parseFacet.firstMatch(in: line)) {
                // triangle normal -- there will be three
                self.normalsBuffer.append(SIMD3(facet.output.1, facet.output.2, facet.output.3))
                self.state = .facet
            } else {
                throw STLError.invalidSTLFormat(line)
            }
        case .facet:
            if (try? self.parseLoop.firstMatch(in: line)) != nil {
                self.state = .loop
            } else if (try? self.parseEndFacet.firstMatch(in: line)) != nil {
                self.state = .solid
            } else {
                throw STLError.invalidSTLFormat(line)
            }
        case .loop:
            if let vertex = try? self.parseVertex.firstMatch(in: line) {
                // triangle vertex -- there will be three
                self.vertexBuffer.append(SIMD3(vertex.output.1, vertex.output.2, vertex.output.3))
            } else if (try? self.parseEndLoop.firstMatch(in: line)) != nil {
                // ordinals for the most recent three triangle vertex
                guard self.vertexBuffer.count % 3 == 0 else {
                    throw STLError.invalidSTLFormat("encountered a triangle without three vertices")
                }
                self.indexBuffer.append(contentsOf: [
                    UInt32(self.vertexBuffer.count-3),
                    UInt32(self.vertexBuffer.count-2),
                    UInt32(self.vertexBuffer.count-1)
                ])
                self.state = .facet
            } else {
                throw STLError.invalidSTLFormat(line)
            }
        case .end:
            self.state = .end
        }
    }
}

/// Interact with STL files.
public enum STL {
    /// Loads a single STL file from an URL asynchronously.
    public static func load(contentsOf: URL, withUnits: STLUnits = STLUnits.meters, materials: [Material] = []) async throws -> ModelEntity {
        // text mode STL is way more common, so we'll look for that first
        var fileType = STLFileType.unknown
        let textParser = try STLTextParser()
        for try await line in contentsOf.lines {
            switch fileType {
            case .unknown:
                if line.starts(with: "solid") {
                    fileType = .text
                    try textParser.process(line)
                } else {
                    fileType = .binary
                }
            case .binary:
                // switching over to binary mode
                break
            case .text:
                // here is the actual parsing
                try textParser.process(line)
            }
        }
        // if we're here -- we have parsed
        switch fileType {
        case .text:
            var descriptor = MeshDescriptor(name: textParser.name)
            descriptor.positions = MeshBuffers.Positions(textParser.vertexBuffer.map { $0 * withUnits.rawValue })
            descriptor.primitives = .triangles(textParser.indexBuffer)
            return try await ModelEntity(mesh: .generate(from: [descriptor]), materials: materials)
        case .binary:
            throw STLError.urlNotFound
        case .unknown:
            throw STLError.urlNotFound
        }
    }
}
