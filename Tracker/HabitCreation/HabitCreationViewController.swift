import UIKit

// MARK: protocol HabitCreationViewControllerDelegate

protocol HabitCreationViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, toCategory categoryTitle: String)
}

// MARK: - HabitCreationViewController Class
final class HabitCreationViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private var selectedSchedule: TrackerSchedule?
    private var selectedEmoji: String?
    private var selectedCategoryTitle: String?
    private var selectedColor: UIColor?
    private lazy var categoryStore = TrackerCategoryStore()
    weak var delegate: HabitCreationViewControllerDelegate?
    var editingTracker: Tracker?
    var editingCategoryTitle: String?
    var completedDaysCount: Int = 0
    
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "Header"
        )
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "tracker_name_placeholder".localized
        textField.backgroundColor = .backgroundtracker
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var optionsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .backgroundtracker
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var cancelMainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("cancel_button".localized, for: .normal)
        button.setTitleColor(UIColor(red: 0.96, green: 0.27, blue: 0.28, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.96, green: 0.27, blue: 0.28, alpha: 1.0).cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapCancelMainButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createMainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("create_button".localized, for: .normal)
        button.setTitleColor(.whitetracker, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .graytracker
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapCreateMainButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelMainButton, createMainButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "ColorHeader"
        )
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .whitetracker
        scroll.alwaysBounceVertical = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var scrollContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .whitetracker
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .blacktracker
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    // MARK: - Setup Methods
    private func setupScreen() {
        view.backgroundColor = .whitetracker
        navigationItem.leftBarButtonItem = nil
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(daysCountLabel)
        scrollContentView.addSubview(trackerNameTextField)
        scrollContentView.addSubview(optionsTableView)
        scrollContentView.addSubview(emojiCollectionView)
        scrollContentView.addSubview(colorCollectionView)
        scrollContentView.addSubview(buttonsStackView)
        
        if let tracker = editingTracker {
            title = "edit_habit_title".localized
            createMainButton.setTitle("save_button".localized, for: .normal)
            createMainButton.backgroundColor = .blacktracker
            daysCountLabel.isHidden = false
            daysCountLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("numberOfDays", comment: ""),
                completedDaysCount
            )
            
            trackerNameTextField.text = tracker.title
            selectedCategoryTitle = editingCategoryTitle
            selectedSchedule = tracker.schedule
            selectedEmoji = tracker.emoji
            selectedColor = tracker.color
        } else {
            title = "new_habit_title".localized
            createMainButton.setTitle("create_button".localized, for: .normal)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            scrollContentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            trackerNameTextField.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            optionsTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiCollectionView.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 240),
            
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 30),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 240),
            
            buttonsStackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 40),
            buttonsStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -24)
        ])
        
        if editingTracker != nil {
            NSLayoutConstraint.activate([
                daysCountLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
                daysCountLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
                daysCountLabel.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
                
                trackerNameTextField.topAnchor.constraint(equalTo: daysCountLabel.bottomAnchor, constant: 40)
            ])
        } else {
            trackerNameTextField.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24).isActive = true
        }
    }
    
    // MARK: - Private Methods
    
    @objc private func didTapCancelMainButton() {
        dismiss(animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func didTapCreateMainButton() {
        guard let trackerTitle = trackerNameTextField.text, !trackerTitle.isEmpty else { return }
        
        let schedule = selectedSchedule ?? TrackerSchedule(
            monday: false, tuesday: false, wednesday: false,
            thursday: false, friday: false, saturday: false, sunday: false
        )
        
        let trackerID = editingTracker?.id ?? UUID()
        
        let updatedTracker = Tracker(
            id: trackerID,
            title: trackerTitle,
            color: selectedColor ?? .greentracker,
            emoji: selectedEmoji ?? "",
            schedule: schedule
        )
        
        let trackerStore = TrackerStore()
        let targetCategoryTitle = selectedCategoryTitle ?? "default_category_title".localized
        
        do {
            try self.categoryStore.addCategory(title: targetCategoryTitle)
            
            if let categoryCoreData = try self.categoryStore.fetchCategoryCoreData(with: targetCategoryTitle) {
                if editingTracker != nil {
                    try trackerStore.updateTracker(updatedTracker, categoryCoreData: categoryCoreData)
                } else {
                    try trackerStore.createTracker(updatedTracker, categoryCoreData: categoryCoreData)
                }
                CoreDataStack.shared.saveContext()
            }
        } catch {
            print("❌ Ошибка при сохранении трекера в Core Data: \(error)")
            assertionFailure("Не удалось сохранить трекер: \(error.localizedDescription)")
        }
        delegate?.didCreateTracker(updatedTracker, toCategory: targetCategoryTitle)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension HabitCreationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "OptionCell")
        
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .blacktracker
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "category_title".localized
            cell.detailTextLabel?.text = selectedCategoryTitle ?? ""
        } else {
            cell.textLabel?.text = "schedule_title".localized
            cell.detailTextLabel?.text = selectedSchedule?.getShortString() ?? ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let categoryVC = CategorySelectionViewController()
            categoryVC.delegate = self
            categoryVC.initialSelectedCategory = self.selectedCategoryTitle
            navigationController?.pushViewController(categoryVC, animated: true)
        }
        else if indexPath.row == 1 {
            print("Переход на экран выбора Расписания")
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
}

extension HabitCreationViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ schedule: TrackerSchedule) {
        self.selectedSchedule = schedule
        optionsTableView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension HabitCreationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return TrackerResources.emojis.count
        } else {
            return TrackerResources.colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            
            let emoji = TrackerResources.emojis[indexPath.item]
            let isSelected = (emoji == selectedEmoji)
            cell.configure(with: emoji, isSelected: isSelected)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            
            let color = TrackerResources.colors[indexPath.item]
            let isSelected = (color == selectedColor)
            cell.configure(with: color, isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = TrackerResources.emojis[indexPath.item]
            emojiCollectionView.reloadData()
        } else {
            selectedColor = TrackerResources.colors[indexPath.item]
            colorCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width
        let sideLength = floor(availableWidth / 6)
        return CGSize(width: sideLength, height: sideLength)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if collectionView == emojiCollectionView {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
                header.subviews.forEach { $0.removeFromSuperview() }
                
                let label = UILabel()
                label.text = "emoji_header_title".localized
                label.font = .systemFont(ofSize: 19, weight: .bold)
                label.textColor = .blacktracker
                label.translatesAutoresizingMaskIntoConstraints = false
                
                header.addSubview(label)
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 12),
                    label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -12),
                    label.topAnchor.constraint(equalTo: header.topAnchor, constant: 0)
                ])
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ColorHeader", for: indexPath)
                header.subviews.forEach { $0.removeFromSuperview() }
                
                let label = UILabel()
                label.text = "color_header_title".localized
                label.font = .systemFont(ofSize: 19, weight: .bold)
                label.textColor = .blacktracker
                label.translatesAutoresizingMaskIntoConstraints = false
                
                header.addSubview(label)
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 12),
                    label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -24),
                    label.topAnchor.constraint(equalTo: header.topAnchor, constant: 0)
                ])
                return header
            }
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 48)
    }
}

// MARK: - CategorySelectionViewControllerDelegate

extension HabitCreationViewController: CategorySelectionViewControllerDelegate {
    func didSelectCategory(_ categoryTitle: String) {
        self.selectedCategoryTitle = categoryTitle
        self.optionsTableView.reloadData()
    }
}
