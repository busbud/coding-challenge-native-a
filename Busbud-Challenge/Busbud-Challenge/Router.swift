//
//  Router.swift
//  Busbud-Challenge
//
//  Created by Julien Saad on 2015-03-03.
//  Copyright (c) 2015 Julien Saad. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    static let baseURLString = "https://busbud-napi-prod.global.ssl.fastly.net"
    static var BusbudToken: String?
    
    case Authorize
    case SearchOrigin(lang: String, limit: String, lat: String, lon: String)
    case SearchDest(lang: String, limit: String, lat: String, lon: String, originId: String)
    
    var method: Alamofire.Method {
        switch self {
        case .Authorize:
            return .GET
        case .SearchOrigin:
            return .GET
        case .SearchDest:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .Authorize:
            return "/auth/guest"
        case .SearchOrigin:
            return "/search"
        case .SearchDest:
            return "/search"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSURLRequest {
        let URL = NSURL(string: Router.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = Router.BusbudToken {
            mutableURLRequest.setValue(token, forHTTPHeaderField: "X-Busbud-Token")
        }
        
        switch self {
        case .Authorize:
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0
        case .SearchOrigin(let lang, let limit, let lat, let lon):
            let parameters = ["lang":lang, "limit":limit, "lat":lat, "lon":lon]
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .SearchDest(let lang, let limit, let lat, let lon, let originId):
            let parameters = ["lang":lang, "limit":limit, "lat":lat, "lon":lon, "originId":originId]
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        default:
            return mutableURLRequest
        }
    }
}