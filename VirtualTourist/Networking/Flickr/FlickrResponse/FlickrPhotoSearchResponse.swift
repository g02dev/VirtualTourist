// 

import Foundation


struct FlickrPhotoSearchResponse: Codable {
    
    struct PhotosResponse: Codable {
        let page: Int
        let pages: Int
        let perpage: Int
        let total: Int
        let photo: [PhotoResponse]
    }
    
    struct PhotoResponse: Codable {
        let title: String
        let url: URL
        
        enum CodingKeys: String, CodingKey {
            case title
            case url = "url_m"
        }
    }
    
    let stat: String
    let photos: PhotosResponse
}


// MARK: - Example
//
//{"photos":{"page":2,"pages":4938,"perpage":5,"total":24688,"photo":[{"id":"51364423750","owner":"40608033@N00","secret":"730bcec839","server":"65535","farm":66,"title":"P8070023 Sun Fly","ispublic":1,"isfriend":0,"isfamily":0},{"id":"51362578332","owner":"76994633@N05","secret":"661457c027","server":"65535","farm":66,"title":"KEW Gardens' Photo Contest Winners Listing","ispublic":1,"isfriend":0,"isfamily":0},{"id":"48036584058","owner":"41087279@N00","secret":"6fbdf32a29","server":"65535","farm":66,"title":"DSC_2836 Positive Runway Model Auditions London 2019","ispublic":1,"isfriend":0,"isfamily":0},{"id":"51363720304","owner":"99245765@N00","secret":"2d57ac88b1","server":"65535","farm":66,"title":"Dilligaf House Boat, Regent's Canal, North Kensington","ispublic":1,"isfriend":0,"isfamily":0},{"id":"51362226912","owner":"99245765@N00","secret":"96a2829e28","server":"65535","farm":66,"title":"Kensal Green Cemetery","ispublic":1,"isfriend":0,"isfamily":0}]},"stat":"ok"}
