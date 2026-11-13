import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerSnapshotTests: XCTestCase {
    
    func testTrackersViewControllerLightTheme() {
        let vc = TrackersViewController()
        let navController = UINavigationController(rootViewController: vc)
        
        assertSnapshot(
            of: navController,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light)),
        )
    }
    
    func testTrackersViewControllerDarkTheme() {
        let vc = TrackersViewController()
        let navController = UINavigationController(rootViewController: vc)
        
        assertSnapshot(
            of: navController,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
        )
    }
}
