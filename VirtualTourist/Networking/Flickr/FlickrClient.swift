// 

import Foundation


class FlickrClient {
    
    #warning("Set valid apiKey. Test https://www.flickr.com/services/api/explore/flickr.test.echo")
    private let apiKey = "f128e818820986014fcbbb5a4bf1ac86"
    private let urlBase = "https://www.flickr.com/services/rest/"
    // https://www.flickr.com/services/api/explore/flickr.photos.search
    
    func getSearchPhotoUrl(latitude: Double, longitude: Double, numberOfPhotos: Int) -> URL? {
        var components = URLComponents(string: urlBase)!
        
        let numberOfSamples = 3
        let perPage = numberOfPhotos * numberOfSamples
        
        components.queryItems = [
            .init(name: "method", value: "flickr.photos.search"),
            .init(name: "format", value: "json"),
            .init(name: "nojsoncallback", value: "1"),
            .init(name: "api_key", value: apiKey),
            .init(name: "lat", value: String(latitude)),
            .init(name: "lon", value: String(longitude)),
            .init(name: "page", value: "1"),
            .init(name: "per_page", value: String(perPage))
        ]
        return components.url
    }
    
    func searchPhoto(latitude: Double, longitude: Double, numberOfPhotos: Int, completion: @escaping (Result<[FlickrPhoto], FlickrError>) -> Void) {
       
        let url = getSearchPhotoUrl(latitude: latitude, longitude: longitude, numberOfPhotos: numberOfPhotos)!
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    let error = FlickrError.clientError(message: error?.localizedDescription)
                    completion(.failure(error))
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            if let responseObject = try? decoder.decode(FlickrPhotoSearchResponse.self, from: data) {
                let photosResponse = responseObject.photos.photo
                let sampleSize = min(photosResponse.count, numberOfPhotos)
                let photosResponseSample = photosResponse.shuffled()[0..<sampleSize]
                let photosSample = photosResponseSample.map{ FlickrPhoto(title: $0.title, url: $0.url) }
                
                DispatchQueue.main.async {
                    completion(.success(photosSample))
                }
            } else if let responseError = try? decoder.decode(FlickrErrorResponse.self, from: data) {
                let error = FlickrError.serverError(message: responseError.message)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(.unknownError))
                }
            }
        }
        task.resume()
    }
}
