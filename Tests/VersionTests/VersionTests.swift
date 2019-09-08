import XCTest
@testable import Version

@available(iOS 13.0, *)
final class VersionTests: XCTestCase {
    
    func testCommonInit() {
        let versionTest1: Version = "1.0.0"
        XCTAssertEqual(versionTest1, try! Version(major: 1, minor: 0, patch: 0, prerelease: nil, metadata: nil))
        let versionTest2: Version = "1.2.3"
        XCTAssertEqual(versionTest2, try! Version(major: 1, minor: 2, patch: 3, prerelease: nil, metadata: nil))
        let versionTest3: Version = "1.2.3-prerelease"
        XCTAssertEqual(versionTest3, try! Version(major: 1, minor: 2, patch: 3, prerelease: "prerelease", metadata: nil))
        let versionTest4: Version = "1.2.3+metadata"
        XCTAssertEqual(versionTest4, try! Version(major: 1, minor: 2, patch: 3, prerelease: nil, metadata: "metadata"))
        let versionTest5: Version = "1.2.3-prerelease+metadata"
        XCTAssertEqual(versionTest5, try! Version(major: 1, minor: 2, patch: 3, prerelease: "prerelease", metadata: "metadata"))
        let versionTest6: Version = "1.2.3-prerelease+01"
        XCTAssertEqual(versionTest6, try! Version(major: 1, minor: 2, patch: 3, prerelease: "prerelease", metadata: "01"))
    }
    
    func testMajorOnlyInit() {
        let versionTest1: Version = "1"
        XCTAssertEqual(versionTest1, try! Version(major: 1, minor: 0, patch: 0, prerelease: nil, metadata: nil))
        let versionTest2: Version = "1-prerelease"
        XCTAssertEqual(versionTest2, try! Version(major: 1, minor: 0, patch: 0, prerelease: "prerelease", metadata: nil))
        let versionTest3: Version = "1+metadata"
        XCTAssertEqual(versionTest3, try! Version(major: 1, minor: 0, patch: 0, prerelease: nil, metadata: "metadata"))
        let versionTest4: Version = "1-prerelease+metadata"
        XCTAssertEqual(versionTest4, try! Version(major: 1, minor: 0, patch: 0, prerelease: "prerelease", metadata: "metadata"))
    }
    
    func testMajorAndMinorInit() {
        let versionTest1: Version = "1.2"
        XCTAssertEqual(versionTest1, try! Version(major: 1, minor: 2, patch: 0, prerelease: nil, metadata: nil))
        let versionTest2: Version = "1.2-prerelease"
        XCTAssertEqual(versionTest2, try! Version(major: 1, minor: 2, patch: 0, prerelease: "prerelease", metadata: nil))
        let versionTest3: Version = "1.2+metadata"
        XCTAssertEqual(versionTest3, try! Version(major: 1, minor: 2, patch: 0, prerelease: nil, metadata: "metadata"))
        let versionTest4: Version = "1.2-prerelease+metadata"
        XCTAssertEqual(versionTest4, try! Version(major: 1, minor: 2, patch: 0, prerelease: "prerelease", metadata: "metadata"))
    }
    
    func testStrictEnforcement() {
        XCTAssertEqual(try? Version("1", strict: true), nil)
        XCTAssertEqual(try? Version("1.2", strict: true), nil)
        XCTAssertEqual(try? Version("1.2-prerelease", strict: true), nil)
        XCTAssertEqual(try? Version("1.2+metadata", strict: true), nil)
        XCTAssertEqual(try? Version("1.2-prerelease+metadata", strict: true), nil)
        XCTAssertEqual(try? Version("1.2.3", strict: true), try! Version(major: 1, minor: 2, patch: 3))
    }
    
    func testMalformedStringsFail() {
        let failureCases: [Version] = ["", "garbage", "1garbage", "005", "01.2.3", "1.2.3-beta.01", "1..2..3", "1.2garbage", "1.2.3garbage", "1.2.3-σ"]
        failureCases.forEach { version in
            XCTAssertEqual(version, try! Version(major: 0))
        }
    }
    
    static var allTests = [
        ("testCommonInit", testCommonInit),
        ("testMajorOnlyInit", testMajorOnlyInit),
        ("testMajorAndMinorInit", testMajorAndMinorInit),
        ("testStrictEnforcement", testStrictEnforcement),
        ("testMalformedStringsFail", testMalformedStringsFail)
    ]
}
