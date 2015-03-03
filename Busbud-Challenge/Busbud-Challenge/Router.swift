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
    static var limit = 5
    
    case Authorize
    case SearchOrigin(lang: String, lat: String, lon: String)
    case SearchDest(q: String, lang: String, lat: String, lon: String, originId: String)
    case WebView(lang: String, originUrl: String, destUrl: String)
    
    var method: Alamofire.Method {
        switch self {
        case .Authorize:
            return .GET
        case .SearchOrigin:
            return .GET
        case .SearchDest:
            return .GET
        case .WebView:
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
        case .WebView(let lang, let originUrl, let destUrl):
            return "https://www.busbud.com/\(lang)/bus-schedules/\(originUrl)/\(destUrl)"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSURLRequest {
        var URL: NSURL
        var mutableURLRequest: NSMutableURLRequest
        switch self {
        case .WebView:
            URL = NSURL(string: path)!
            mutableURLRequest = NSMutableURLRequest(URL: URL)
        default:
            URL = NSURL(string: Router.baseURLString)!
            mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        }
        
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = Router.BusbudToken {
            mutableURLRequest.setValue(token, forHTTPHeaderField: "X-Busbud-Token")
        }
        
        switch self {
        case .Authorize:
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0
        case .SearchOrigin(let lang, let lat, let lon):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["lang":lang, "limit":Router.limit, "lat":lat, "lon":lon]).0
        case .SearchDest(let q, let lang, let lat, let lon, let originId):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["q":q, "lang":lang, "limit":Router.limit, "lat":lat, "lon":lon, "originId":originId]).0
        default:
            return mutableURLRequest
        }
    }
}