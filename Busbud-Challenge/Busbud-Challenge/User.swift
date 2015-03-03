//
//  User.swift
//  Busbud-Challenge
//
//  Created by Julien Saad on 2015-03-03.
//  Copyright (c) 2015 Julien Saad. All rights reserved.
//

import Foundation

class User {
    
    let language: String
    var latitude: String
    var longitude: String
    
    init(language:String, latitude:String, longitude:String) {
        self.language = language
        self.latitude = latitude
        self.longitude = longitude
    }
    
    convenience init(language:String){
        self.init(language: language, latitude: "", longitude: "")
    }
}