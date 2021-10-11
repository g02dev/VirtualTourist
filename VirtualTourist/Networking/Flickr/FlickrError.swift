// 

import Foundation


enum FlickrError: Error  {
    case clientError(message: String?)
    case serverError(message: String?)
    case unknownError
}

extension FlickrError: CustomStringConvertible {
    var description: String {
        switch self {
        case .clientError(let message):
            return message ?? "Unknown client error"
        case .serverError(let message):
            return message ?? "Unknown server error"
        case .unknownError:
            return "Unknown error"
        }
    }
}
