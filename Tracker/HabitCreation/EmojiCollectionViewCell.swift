import UIKit

// MARK: - EmojiCell Class

final class EmojiCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "EmojiCell"
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(emojiLabel)
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        
        backgroundColor = isSelected ? UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) : .clear
    }
}
