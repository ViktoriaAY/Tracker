import UIKit

// MARK: - ColorCell Class

final class ColorCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = "ColorCell"
    
    // MARK: - Properties
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 3
        contentView.layer.borderColor = UIColor.clear.cgColor
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        
        if isSelected {
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            contentView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
