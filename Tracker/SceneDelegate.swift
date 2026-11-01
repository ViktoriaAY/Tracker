import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if hasSeenOnboarding {
            
            let trackersVC = TrackersViewController()
            let trackersNav = UINavigationController(rootViewController: trackersVC)
            trackersNav.navigationBar.prefersLargeTitles = true
            trackersNav.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(systemName: "record.circle.fill"), tag: 0)
            
            let statisticsVC = UIViewController()
            
            statisticsVC.view.backgroundColor = .white
            let statisticsNav = UINavigationController(rootViewController: statisticsVC)
            statisticsNav.navigationBar.prefersLargeTitles = true
            statisticsNav.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), tag: 1)
            
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = [trackersNav, statisticsNav]
            
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = .white
            tabBarController.tabBar.standardAppearance = appearance
            tabBarController.tabBar.scrollEdgeAppearance = appearance
            tabBarController.tabBar.tintColor = .systemBlue
            
            window.rootViewController = tabBarController
        } else {
            window.rootViewController = OnboardingViewController()
        }
        self.window = window
        window.makeKeyAndVisible()
    }
    
}

