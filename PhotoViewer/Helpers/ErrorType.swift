import Foundation

enum ErrorType: Error {
    case wrongURL
    case noData
    case error(Error)
    case unexped
}
