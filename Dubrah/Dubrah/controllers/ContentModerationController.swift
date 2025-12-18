import UIKit

class ContentModerationController: BaseViewController, UIPageViewControllerDataSource  {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pageContainerView: UIView!

    private var pageViewController: UIPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ ContentModerationController loaded")
        setupPageVC()
    }

    private func setupPageVC() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )

        pageViewController.dataSource = self

        addChild(pageViewController)
        pageContainerView.addSubview(pageViewController.view)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: pageContainerView.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: pageContainerView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: pageContainerView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: pageContainerView.trailingAnchor)
        ])

        pageViewController.didMove(toParent: self)

        showInitialPage()
    }

    private func showInitialPage() {
        pageViewController.setViewControllers(
            [usersVC],
            direction: .forward,
            animated: false
        )
    }

    // MARK: - Page Data Source
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        return nil
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        return nil
    }

    private lazy var usersVC: UIViewController = {
        UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "users")
    }()

    private lazy var categoriesVC: UIViewController = {
        UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "categories")
    }()

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {

        let selectedVC = sender.selectedSegmentIndex == 0
            ? usersVC
            : categoriesVC

        let direction: UIPageViewController.NavigationDirection =
            sender.selectedSegmentIndex == 0 ? .reverse : .forward

        pageViewController.setViewControllers(
            [selectedVC],
            direction: direction,
            animated: true
        )
    }
}
