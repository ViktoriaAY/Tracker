import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(_ schedule: TrackerSchedule)
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private enum WeekdayIndex: Int, CaseIterable {
        case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday
        
        var russianName: String {
            switch self {
            case .monday: return "Понедельник"
            case .tuesday: return "Вторник"
            case .wednesday: return "Среда"
            case .thursday: return "Четверг"
            case .friday: return "Пятница"
            case .saturday: return "Суббота"
            case .sunday: return "Воскресенье"
            }
        }
    }
    
    private var mondayState = false
    private var tuesdayState = false
    private var wednesdayState = false
    private var thursdayState = false
    private var fridayState = false
    private var saturdayState = false
    private var sundayState = false
    
    // MARK: - UI Elements
    
    private lazy var scheduleTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .backgroundtracker
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WeekdayCell")
        
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blacktracker
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    private func setupScreen() {
        view.backgroundColor = .white
        title = "Расписание"
        
        view.addSubview(scheduleTableView)
        view.addSubview(doneButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
    
            scheduleTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    
    // MARK: - Actions
    @objc private func switchChanged(_ sender: UISwitch) {
        switch sender.tag {
        case 0: mondayState = sender.isOn
        case 1: tuesdayState = sender.isOn
        case 2: wednesdayState = sender.isOn
        case 3: thursdayState = sender.isOn
        case 4: fridayState = sender.isOn
        case 5: saturdayState = sender.isOn
        case 6: sundayState = sender.isOn
        default: break
        }
    }
    
    @objc private func didTapDoneButton() {
        let finalSchedule = TrackerSchedule(
            monday: mondayState,
            tuesday: tuesdayState,
            wednesday: wednesdayState,
            thursday: thursdayState,
            friday: fridayState,
            saturday: saturdayState,
            sunday: sundayState
        )
        delegate?.didSelectSchedule(finalSchedule)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekdayIndex.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekdayCell", for: indexPath)
        
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        guard let day = WeekdayIndex(rawValue: indexPath.row) else { return cell }
        cell.textLabel?.text = day.russianName
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.textLabel?.textColor = .black
        
        let switchView = UISwitch()
        switchView.onTintColor = .systemBlue
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        switch indexPath.row {
        case 0: switchView.isOn = mondayState
        case 1: switchView.isOn = tuesdayState
        case 2: switchView.isOn = wednesdayState
        case 3: switchView.isOn = thursdayState
        case 4: switchView.isOn = fridayState
        case 5: switchView.isOn = saturdayState
        case 6: switchView.isOn = sundayState
        default: switchView.isOn = false
        }
        
        cell.accessoryView = switchView
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

