// 

import Foundation


struct FlickrErrorResponse: Codable {
    let stat: String
    let code: Int
    let message: String
}

// MARK: - Example
//
// {"stat":"fail","code":3,"message":"Parameterless searches have been disabled. Please use flickr.photos.getRecent instead."}
