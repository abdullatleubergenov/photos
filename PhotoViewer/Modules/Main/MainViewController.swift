import UIKit

protocol MainViewProtocol: AnyObject {
    func reloadData()
    func insertItems(at indexPath: IndexPath, items: [MainModel])
    func route(to viewController: UIViewController)
    func present(viewController: UIViewController)
}

class MainViewController: BaseViewController {
    
    // MARK: - Props
    
    private lazy var collectionView: UICollectionView = {
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(1.0))
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            group.interItemSpacing = .fixed(8.0)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8.0
            section.contentInsets = .init(top: 0.0, leading: 16.0, bottom: 0.0, trailing: 16.0)
            
            return section
        }, configuration: layoutConfig)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = .init(top: 16.0, left: 0.0, bottom: 24.0, right: 0.0)
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.register(PhotoCollectionCell.self, forCellWithReuseIdentifier: PhotoCollectionCell.cellId)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        button.addTarget(self, action: #selector(didTapSort(_:)), for: .touchUpInside)
        
        return button
    }()
    
    var presenter: MainPresenterProtocol!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Photos"
        presenter.viewDidLoad()
        setupRigthBarButton()
    }
    
    override func embedSubviews() {
        view.addSubview(collectionView)
    }
    
    override func setSubviewsConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

// MARK: - Protocol Methods

extension MainViewController: MainViewProtocol {
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func insertItems(at indexPath: IndexPath, items: [MainModel]) {
        let indexPaths = items.enumerated().map { index, _ in
            IndexPath(
                item: collectionView.numberOfItems(inSection: indexPath.section) + index,
                section: indexPath.section
            )
        }
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: indexPaths)
            presenter.didFinishUpdatingPaginatedObjects()
        }
    }
    
    func route(to viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func present(viewController: UIViewController) {
        present(viewController, animated: true)
    }
    
}

// MARK: - CollectionView DataSource & Delegate Methods

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.cellId, for: indexPath) as? PhotoCollectionCell else {
            return .init()
        }
        
        let item = presenter.items[indexPath.item]
        cell.configure(thumbnailURL: item.thumbnailUrl, title: item.title)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        presenter.fetchMorePhotos(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath.item)
    }
    
}

// MARK: - Privates

fileprivate extension MainViewController {
    
    func setupRigthBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortButton)
    }
    
    @objc func didTapSort(_ button: UIButton) {
        presenter.didTapSort(on: button)
    }
    
}
