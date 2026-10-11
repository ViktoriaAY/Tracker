import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 18.0, *) {
            self.mode = .tabBar
        }
    }
    
    private func setupTabs() {
        let trackersViewController = TrackersViewController()
        
        let trackersNC = UINavigationController(rootViewController: trackersViewController)
        
        trackersNC.navigationBar.prefersLargeTitles = true
        trackersViewController.title = "Трекеры"
        trackersNC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tab_bar_item"),
            selectedImage: nil
        )
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "tab_bar_bunny"),
            selectedImage: nil
        )
        viewControllers = [trackersNC, statisticsVC]
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .whitetracker
        appearance.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .lightGray
    }
}

