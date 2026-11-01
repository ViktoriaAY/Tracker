import UIKit

// MARK: - OnboardingViewController

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Private Properties
    
    private lazy var pages: [UIViewController] = {
        let firstPage = OnboardingPageViewController(
            imageName: "Onboarding1",
            text: "Отслеживайте только то, что хотите",
            buttonText: "Вот это технологии!",
            completion: { [weak self] in self?.switchToMainScreen() }
        )
        
        let secondPage = OnboardingPageViewController(
            imageName: "Onboarding2",
            text: "Даже если это не блины по утрам",
            buttonText: "Вот это технологии!",
            completion: { [weak self] in self?.switchToMainScreen() }
        )
        return [firstPage, secondPage]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = pages.count
        control.currentPage = 0
        control.currentPageIndicatorTintColor = .black // Или .blacktracker
        control.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        control.addTarget(self, action: #selector(didTapPageControl(_:)), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // MARK: - Initializers
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
        setupHierarchy()
        setupConstraints()
    }
    
    // MARK: - Actions
    
    @objc private func didTapPageControl(_ sender: UIPageControl) {
        let targetIndex = sender.currentPage
        let direction: UIPageViewController.NavigationDirection = targetIndex > pageControl.currentPage ? .forward : .reverse
        setViewControllers([pages[targetIndex]], direction: direction, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func setupHierarchy() {
        view.addSubview(pageControl)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
    
    private func switchToMainScreen() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        guard UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) != nil else { return }
        
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }
        
        let trackersVC = TrackersViewController()
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        trackersNav.navigationBar.prefersLargeTitles = true
        
        trackersNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            tag: 0
        )
        
        let statisticsVC = UIViewController()
        statisticsVC.view.backgroundColor = .white
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)
        statisticsNav.navigationBar.prefersLargeTitles = true
        
        statisticsNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"), // Поменяй на свою картинку, если нужно
            tag: 1
        )
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [trackersNav, statisticsNav]
        
        tabBarController.tabBar.tintColor = .systemBlue
        tabBarController.tabBar.backgroundColor = .white
        
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .white
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        
        tabBarController.tabBar.tintColor = .systemBlue
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBarController
        }, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let currentViewController = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = index
        }
    }
}
