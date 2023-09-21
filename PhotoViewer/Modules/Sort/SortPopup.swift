import UIKit

enum SortType: Int, CaseIterable {
    case id
    case albumId
    
    var title: String {
        switch self {
        case .id: return "По ID"
        case .albumId: return "По ID альбома"
        }
    }
}

class SortPopup: UIViewController {
    
    // MARK: - Props
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 12.0
        
        return view
    }()
    
    private let vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 12.0
        stack.axis = .vertical
        stack.distribution = .fillEqually
        
        return stack
    }()
    
    private var topConstraintConstant: CGFloat = .zero
    private var leftConstraintConstant: CGFloat?
    private var rightConstraintConstant: CGFloat?
    private var selectedSortType: SortType?
    private var onDidSelect: (SortType) -> Void
    
    // MARK: - Lifeycle
    
    init(sender: UIView, selectedSortType: SortType?, onDidSelect: @escaping (SortType) -> Void) {
        self.onDidSelect = onDidSelect
        
        super.init(nibName: nil, bundle: nil)
        
        self.selectedSortType = selectedSortType
        
        if let globalFrame = sender.superview?.convert(sender.frame, to: nil) {
            topConstraintConstant = globalFrame.maxY
            
            if globalFrame.minX <= 64.0 {
                leftConstraintConstant = globalFrame.minX
            } else {
                rightConstraintConstant = globalFrame.maxX
            }
        }
        
        modalPresentationCapturesStatusBarAppearance = true
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        configureItems()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
    
}

// MARK: - Privates

fileprivate extension SortPopup {
    
    func setupSubviews() {
        view.addSubview(contentView)
        contentView.addSubview(vStack)
        
        contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: topConstraintConstant).isActive = true
        
        if let leftConstraintConstant {
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: leftConstraintConstant).isActive = true
        } else {
            contentView.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 16.0).isActive = true
        }
        
        if let rightConstraintConstant {
            let constant = view.frame.width - rightConstraintConstant
            contentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -constant).isActive = true
        } else {
            contentView.rightAnchor.constraint(lessThanOrEqualTo: view.leftAnchor, constant: -16.0).isActive = true
        }
        
        contentView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16.0).isActive = true
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.0),
            vStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12.0),
            vStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12.0),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.0)
        ])
    }
    
    func configureItems() {
        SortType.allCases.forEach { type in
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = type.rawValue
            button.contentHorizontalAlignment = .leading
            button.setAttributedTitle(createAttrsFor(title: type.title, isSelected: false), for: .normal)
            button.setAttributedTitle(createAttrsFor(title: type.title, isSelected: true), for: .selected)
            button.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
            vStack.addArrangedSubview(button)
        }
    }
    
    func createAttrsFor(title: String, isSelected: Bool) -> NSAttributedString {
        NSAttributedString(
            string: title,
            attributes: [
                .foregroundColor: isSelected ? UIColor.blue : UIColor.black,
                .font: UIFont.systemFont(ofSize: 13.0, weight: .medium)
            ]
        )
    }
    
    @objc func didSelect(_ button: UIButton) {
        button.isSelected.toggle()
        onDidSelect(SortType(rawValue: button.tag)!)
        dismiss(animated: true)
    }
    
}
