//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Sameer Almutairi on 07/06/2019.
//  Copyright © 2019 Sameer Almutairi. All rights reserved.
//

import Foundation

class FlickrClient {
    
    static var apiKey = "ebd5796727fdb832b9101baf5afe962b"
    
//    https://www.flickr.com/services/rest/?api_key=ebd5796727fdb832b9101baf5afe962b&method=flickr.photos.search&format=json&bbox=44.1783599468599,23.685184665130038,45.1783599468599,24.685184665130038
//    &nojsoncallback=1&page=1&per_page=9
    
    enum endpoints {
        static let base: String = "https://api.flickr.com/services/rest/"
        static let extras: String = "url_m"
        static let currentPage: String = ""
        static let perPage: String = "10"
        static let searchMethod: String = "flickr.photos.search"
        static let radiusUnits: String = "km"
        static let radius: String = "10"
//        var page = Int.random(in: 1 ... )
        case PhotosSearch(Double,Double,Int)
        
        var stringValues: String {
            switch self {
            case .PhotosSearch(let lon, let lat, let page):
                return endpoints.base + "?api_key=\(apiKey)&format=json&nojsoncallback=1&extras=url_m&lon=\(lon)&lat=\(lat)&page=\(page)&per_page=\(endpoints.perPage)&method=\(endpoints.searchMethod)&radius_units=\(endpoints.radiusUnits)&radius=\(endpoints.radius)"
            }
        }
        var url: URL {
            return URL(string: stringValues)!
        }
    }
    
    class func getPhotoForCoordinate(lon: Double, lat: Double,page: Int, completion: @escaping ([PhotoDetails]?, Error?) -> Void){
        taskForGETRequest(url: FlickrClient.endpoints.PhotosSearch(lon, lat, page).url, responseType: PhotosResponse.self) { (response, error) in
            if let response = response {
                completion(response.photos.photo, nil)
            }
            else {
                print(error!)
            }
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask{
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
}


        //api.flickr.com/services/rest/?format=json&nojsoncallback=1&lon=39.58260213674495&lat=24.51025157026407&page=35&api_key=56d3b0ffbb62c2abda740147deca2b7f&extras=url_m&per_page=10&method=flickr.photos.search&radius_units=km&radius=10

// base : https://api.flickr.com/services/rest/
// format = json
// ojsoncallback = 1
// lon =
// lat =
// page =
// apiKey = "ebd5796727fdb832b9101baf5afe962b"
// extras = url_m
// per_page = 10
// method = flickr.photos.search
// radius_units = km
// radius = 10

//{
//    "photos": {
//        "page": 1,
//        "pages": 16,
//        "perpage": 9,
//        "total": "141",
//        "photo": [
//        {
//        "id": "41774814685",
//        "owner": "157696020@N02",
//        "secret": "858c77a9b1",
//        "server": "1738",
//        "farm": 2,
//        "title": "04 Ithra Youth Initiative",
//        "ispublic": 1,
//        "isfriend": 0,
//        "isfamily": 0
//        },
//        {
//        "id": "40546278064",
//        "owner": "7204348@N05",
//        "secret": "28757b570e",
//        "server": "805",
//        "farm": 1,
//        "title": "# #📹 #sony #sonyalpha #رالي #car #cars #photos #saudiarabia #ksa #Rally #landscapes  #landscape #naturephoto #motorcycle #motorcycles #goodevening #الجمعة #panorama #photo #تطعيس #good_evening #mountains #sony_alpha #bw #nature #landscapehunt",
//        "ispublic": 1,
//        "isfriend": 0,
//        "isfamily": 0
//        }
//        ]
//    },
//    "stat": "ok"
//}

// https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg

//https://farm2.staticflickr.com/1738/41774814685_858c77a9b1.jpg

//https://api.flickr.com/services/rest/?format=json&nojsoncallback=1&lon=39.58260213674495&lat=24.51025157026407&page=35&api_key=56d3b0ffbb62c2abda740147deca2b7f&extras=url_m&per_page=10&method=flickr.photos.search&radius_units=km&radius=10

// base : https://api.flickr.com/services/rest/
// format=json
// ojsoncallback = 1
// lon =
// lat =
// page =
// apiKey = "ebd5796727fdb832b9101baf5afe962b"
// extras = url_m
// per_page = 10
// method = flickr.photos.search
// radius_units = km
// radius = 10

