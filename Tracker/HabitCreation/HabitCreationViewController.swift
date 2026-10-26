import UIKit

// MARK: protocol HabitCreationViewControllerDelegate

protocol HabitCreationViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, toCategory categoryTitle: String)
}

// MARK: - HabitCreationViewController Class
final class HabitCreationViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private var selectedSchedule: TrackerSchedule?
    private let emojis = [
        "😊", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    private var selectedEmoji: String?
    weak var delegate: HabitCreationViewControllerDelegate?
    
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
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1.0)
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
        tableView.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1.0)
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
        button.setTitle("Отменить", for: .normal)
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
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(red: 0.68, green: 0.69, blue: 0.71, alpha: 1.0)
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
    
    private let colors: [UIColor] = [
        UIColor(red: 0.99, green: 0.30, blue: 0.29, alpha: 1.0),
        UIColor(red: 1.00, green: 0.60, blue: 0.41, alpha: 1.0),
        UIColor(red: 0.41, green: 0.49, blue: 0.95, alpha: 1.0),
        UIColor(red: 0.53, green: 0.37, blue: 0.95, alpha: 1.0),
        UIColor(red: 0.35, green: 0.82, blue: 0.42, alpha: 1.0),
        UIColor(red: 0.90, green: 0.42, blue: 0.74, alpha: 1.0),
        UIColor(red: 0.97, green: 0.75, blue: 0.73, alpha: 1.0),
        UIColor(red: 0.41, green: 0.69, blue: 0.94, alpha: 1.0),
        UIColor(red: 0.37, green: 0.85, blue: 0.66, alpha: 1.0),
        UIColor(red: 0.43, green: 0.33, blue: 0.78, alpha: 1.0),
        UIColor(red: 0.93, green: 0.45, blue: 0.33, alpha: 1.0),
        UIColor(red: 1.00, green: 0.66, blue: 0.81, alpha: 1.0),
        UIColor(red: 0.96, green: 0.76, blue: 0.55, alpha: 1.0),
        UIColor(red: 0.54, green: 0.64, blue: 0.94, alpha: 1.0),
        UIColor(red: 0.43, green: 0.16, blue: 0.92, alpha: 1.0),
        UIColor(red: 0.68, green: 0.34, blue: 0.85, alpha: 1.0),
        UIColor(red: 0.53, green: 0.37, blue: 0.95, alpha: 1.0),
        UIColor(red: 0.18, green: 0.82, blue: 0.35, alpha: 1.0)
    ]
    
    private var selectedColor: UIColor?
    
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
        scroll.backgroundColor = .white
        scroll.alwaysBounceVertical = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var scrollContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var categoryStore = TrackerCategoryStore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    // MARK: - Setup Methods
    private func setupScreen() {
        view.backgroundColor = .white
        title = "Новая привычка"
        navigationItem.leftBarButtonItem = nil
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(trackerNameTextField)
        scrollContentView.addSubview(optionsTableView)
        scrollContentView.addSubview(emojiCollectionView)
        scrollContentView.addSubview(colorCollectionView)
        scrollContentView.addSubview(buttonsStackView)
        
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
            
            trackerNameTextField.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
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
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 220),
            
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 30),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 220),
            
            buttonsStackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 40),
            buttonsStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -24)
        ])
    }
    
    // MARK: - Private Methods
    
    @objc private func didTapCancelMainButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateMainButton() {
        guard let trackerTitle = trackerNameTextField.text, !trackerTitle.isEmpty else { return }
        
        let schedule = selectedSchedule ?? TrackerSchedule(
            monday: false, tuesday: false, wednesday: false,
            thursday: false, friday: false, saturday: false, sunday: false
        )
        
        let newTracker = Tracker(
            id: UUID(),
            title: trackerTitle,
            color: selectedColor ?? .greentracker,
            emoji: selectedEmoji ?? "",
            schedule: schedule
        )
        
        let trackerStore = TrackerStore()
        
        do {
            try self.categoryStore.addCategory(title: "Домашний уют")
            if let categoryCoreData = try self.categoryStore.fetchCategoryCoreData(with: "Домашний уют") {
                try trackerStore.createTracker(newTracker, categoryCoreData: categoryCoreData)
                CoreDataStack.shared.saveContext()
            }
        } catch {
            print("Ошибка при записи трекера в базу данных: \(error)")
        }

        delegate?.didCreateTracker(newTracker, toCategory: "Домашний уют")
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
        cell.detailTextLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        cell.detailTextLabel?.textColor = .gray
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = ""
        } else {
            cell.textLabel?.text = "Расписание"
            if let schedule = selectedSchedule {
                cell.detailTextLabel?.text = schedule.getShortString()
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
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
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            let isSelected = (emoji == selectedEmoji)
            cell.configure(with: emoji, isSelected: isSelected)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            let color = colors[indexPath.item]
            let isSelected = (color == selectedColor)
            cell.configure(with: color, isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            emojiCollectionView.reloadData()
        } else {
            selectedColor = colors[indexPath.item]
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
                label.text = "Emoji"
                label.font = .systemFont(ofSize: 19, weight: .bold)
                label.textColor = .black
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
                label.text = "Цвет"
                label.font = .systemFont(ofSize: 19, weight: .bold)
                label.textColor = .black
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
