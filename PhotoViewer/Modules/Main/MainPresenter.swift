import Foundation

protocol MainPresenterProtocol: AnyObject {
    var items: [MainModel] { get }
    var isPaginating: Bool { get }
    var isPaginationDone: Bool { get }
    
    func viewDidLoad()
    func fetchMorePhotos(at indexPath: IndexPath)
    func didSelectItem(at item: Int)
    func didFinishUpdatingPaginatedObjects()
    func didTapSort(on view: View)
}

class MainPresenter {
    
    private let service: MainServiceProtocol = MainService()
    
    private var allItems: [MainModel] = []
    
    private(set) var items: [MainModel] = []
    private(set) var isPaginating: Bool = false
    private(set) var isPaginationDone: Bool = false
    
    private weak var view: MainViewProtocol?
    
    init(view: MainViewProtocol) {
        self.view = view
    }
    
}

// MARK: - Protocol Methods

extension MainPresenter: MainPresenterProtocol {
    
    func viewDidLoad() {
        fetchData()
    }
    
    func fetchMorePhotos(at indexPath: IndexPath) {
        guard indexPath.item == (items.count - 1) else { return }
        
        var diff = 0
        
        if allItems.count <= (items.count + 10) {
            diff = (allItems.count - 1) - indexPath.item
        }
        
        if !isPaginationDone && !isPaginating {
            isPaginating = true
            diff = diff > 0 ? diff : 10
            let fetchedItems = Array(allItems[items.count..<(items.count + diff)])
            items += fetchedItems
            view?.insertItems(at: indexPath, items: fetchedItems)
        }
    }
    
    func didSelectItem(at item: Int) {
        let detailedViewController = DetailedViewController()
        detailedViewController.item = items[item]
        view?.route(to: detailedViewController)
    }
    
    func didFinishUpdatingPaginatedObjects() {
        isPaginationDone = allItems.count == items.count
        DispatchQueue.main.async {
            self.isPaginating = false
        }
    }
    
    func didTapSort(on view: View) {
        let sortVC = SortPopup(sender: view, selectedSortType: nil) { [unowned self] sortType in
            switch sortType {
            case .id:
                self.items = self.items.sorted(by: { $0.id < $1.id })
            case .albumId:
                self.items = self.items.sorted(by: { $0.albumId < $1.albumId })
            }
            self.view?.reloadData()
        }
        self.view?.present(viewController: sortVC)
    }
    
}

// MARK: - Privates

fileprivate extension MainPresenter {
    
    func fetchData() {
        service.fetchPhotos { [weak self] result in
            switch result {
            case .success(let items):
                self?.allItems = items
                
                if items.count >= 10 {
                    self?.items = Array(items[0..<10])
                } else {
                    self?.items = items
                }
                
                self?.view?.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}
