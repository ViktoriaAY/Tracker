import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func didTapCompleteButton(in cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TrackerCollectionViewCell"
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    // MARK: - UI Elements
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
   
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .whitetracker
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .blacktracker
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 17
        button.tintColor = .whitetracker
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration Method
    
    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int) {
        titleLabel.text = tracker.title
        titleLabel.textColor = .whitetracker
        cardView.backgroundColor = tracker.color
        
        emojiLabel.text = tracker.emoji
        
        daysLabel.text = "\(completedDays) дней"
        daysLabel.textColor = .blacktracker
        
        completeButton.backgroundColor = tracker.color
        
        if isCompleted {
            let doneImage = UIImage(systemName: "checkmark")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .bold))
            completeButton.setImage(doneImage, for: .normal)
        } else {
            let plusImage = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .bold))
            completeButton.setImage(plusImage, for: .normal)
            completeButton.alpha = 1.0
        }
    }

    
    // MARK: - Setup UI
    
    private func setupHierarchy() {
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        
        contentView.addSubview(cardView)
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
    }
    
    private func setupConstraints() {
           NSLayoutConstraint.activate([
               cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
               cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
               cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
               cardView.heightAnchor.constraint(equalToConstant: 90),
               
               emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
               emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
               emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
               emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
               
               emojiLabel.topAnchor.constraint(equalTo: emojiBackgroundView.topAnchor),
               emojiLabel.bottomAnchor.constraint(equalTo: emojiBackgroundView.bottomAnchor),
               emojiLabel.leadingAnchor.constraint(equalTo: emojiBackgroundView.leadingAnchor),
               emojiLabel.trailingAnchor.constraint(equalTo: emojiBackgroundView.trailingAnchor),
               
               titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
               titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
               titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
               
               completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
               completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
               completeButton.widthAnchor.constraint(equalToConstant: 34),
               completeButton.heightAnchor.constraint(equalToConstant: 34),
               completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
               
               daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
               daysLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -8),
               daysLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor)
           ])
       }
    
    @objc private func completeButtonTapped() {
        delegate?.didTapCompleteButton(in: self)
    }
}

