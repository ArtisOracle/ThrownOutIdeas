//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

//
//  ObjectMapper.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

protocol Mappable {
    var mappings: [String : (() -> Any?, (Any?) -> Void)] { get }
}

protocol JSONSerializable: Mappable {
    init(dictionary: [String : Any?])
    func toDictionary() -> [String : Any?]
}

//
//  ObjectMapper.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import Foundation

class RootModel: JSONSerializable, NSCoding {
    var str = "Default string"
    var num = 10
    var dbl = 13.3
    
    
    // MARK: - Mappable
    var mappings: [String : (() -> Any?, (Any?) -> Void)] {
        return [
            "a_string": ({ self.str as Any }, { self.str = valueParser($0) ?? self.str }),
            "a_number": ({ self.num as Any }, { self.num = valueParser($0) ?? self.num }),
            "a_double": ({ self.dbl as Any }, { self.dbl = valueParser($0) ?? self.dbl }),
        ]
    }
    
    
    // MARK: - JSONSerializable
    required init(dictionary: [String : Any?]) {
        defaultJSONSerializableInitialization(self, dictionary: dictionary)
    }
    
    func toDictionary() -> [String : Any?] {
        return [:]
    }
    
    // MARK: - NSCoding
    @objc required init(coder aDecoder: NSCoder) {
        
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        
    }
    
}

func defaultJSONSerializableInitialization<T: JSONSerializable>(object: T, #dictionary: [String : Any?]) {
    for (key, value) in dictionary {
        if let m = object.mappings[key] {
            let f = m.1
            f(value)
        }
    }
}

func defaultCoderInitialization<T where T: NSCoding, T: Mappable>(object: T, #coder: NSCoder) {
    for (key, funcs) in object.mappings {
        if let value: AnyObject = coder.decodeObjectForKey(key) {
            let f = funcs.1
            f(value)
        }
    }
}

func valueParser<T>(input: Any?) -> T? {
    var result: T? = nil
    
    if let t = input as? T {
        result = t
    }
    
    return result
}

func modelParser<T where T: RootModel>(input: Any?) -> T? {
    var result: T? = nil
    
    if let t = input as? T {
        result = t
    } else if let dictionary = input as? [String : Any?] {
        result = T(dictionary: dictionary)
    } else if let aDecoder = input as? NSCoder {
        result = T(coder: aDecoder)
    }
    
    return result
}

let r = RootModel(dictionary: ["a_string": "hello, serializer!", "a_number": 1337, "a_double": 123.456])

