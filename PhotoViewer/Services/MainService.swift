import Foundation

protocol MainServiceProtocol {
    func fetchPhotos(_ completion: @escaping (Result<[MainModel], ErrorType>) -> Void)
}

struct MainService: MainServiceProtocol {
    
    func fetchPhotos(_ completion: @escaping (Result<[MainModel], ErrorType>) -> Void) {
        let path = "https://jsonplaceholder.typicode.com/photos"
        
        guard let url = URL(string: path) else {
            completion(.failure(.wrongURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(.error(error)))
                }
            } else {
                guard let data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                do {
                    let resp = try JSONDecoder().decode([MainModel].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(resp))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.error(error)))
                    }
                }
            }
        }.resume()
    }
    
}
