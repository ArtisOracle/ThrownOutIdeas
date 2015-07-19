//: Playground - noun: a place where people can play

import UIKit
import Foundation

//protocol JSONType { }
//extension Int: JSONType { }
//extension Double: JSONType { }
//extension String: JSONType { }
//extension Bool: JSONType { }
//extension Dictionary: JSONType { }
//extension Array: JSONType { }
//extension Optional: JSONType { }

enum Color: String, JSONType {
    case Red = "R"
    case Green = "G"
    case Blue = "B"
    
    init(json: AnyObject) {
        if let str = json as? String,
          let v = Color(rawValue: str) {
            self = v
        } else {
            self = .Red
        }
    }
    
    func toJSON() -> Any {
        return rawValue
    }
}

extension String {
    static func parse(any: Any?) -> String? {
        return any as? String
    }
}

protocol Mappable {
//    var mappings: [String : (() -> Any?, (Any?) -> Void)] { get }
    var mappings: [String : Map] { get }
}

protocol JSONSerializable: Mappable {
    init(dictionary: [String : Any])
    func toDictionary() -> [String : Any]
}

protocol JSONValue {
    typealias T
    static func fromJSON(json: AnyObject) -> T
    func toJSON() -> T
}

extension Int: JSONValue {
    static func fromJSON(json: AnyObject) -> Int {
        return json as? Int ?? Int.max
    }
    
    func toJSON() -> Int {
        return self
    }
}

protocol JSONType {
    init(json: AnyObject)
    func toJSON() -> Any
}

func defaultInitialization<T: JSONSerializable>(object: T, #dictionary: [String : Any]) {
    for (key, value) in dictionary {
        if let m = object.mappings[key] {
            let f = m.to
            f(value)
        }
    }
}

class Bar: Mappable, JSONSerializable {
    var three = false
    var four = 0.1
    
    
    init() {
        
    }
    
    required init(dictionary: [String : Any]) {
        defaultInitialization(self, dictionary: dictionary)
    }
    
    func toDictionary() -> [String : Any] {
        return ["bar":"fuck"]
    }
    
//    var mappings: [String : (() -> Any?, (Any?) -> Void)] {
//        return [
//            "third_boolean": ({ self.three as Any }, { self.three = $0 as! Bool }),
//            "four_double": ({ self.four as Any } , { self.four = $0 as! Double })
//        ]
//    }
    var mappings: [String : Map] {
        return [
            "third_boolean": Map(from: { self.three }, to: { self.three = valueParser($0)! }),
            "four_double": Map(from: { self.four }, to: { self.four = valueParser($0)! }),
        ]
    }
}

class Foo: Mappable, JSONSerializable {
    var someString = "string"
    var someNumber = 10
    var optBar: Bar? = Bar()
    var color: Color = .Red
    var arr = [Bar]()
    
    init() {
        
    }
    
    required init(dictionary: [String : Any]) {
        defaultInitialization(self, dictionary: dictionary)
    }
    
    func toDictionary() -> [String : Any] {
        return jsonObjectMaker(self)
    }
    
//    var mappings: [String : (() -> Any?, (Any?) -> Void)] {
//        return [
//            "a_string": ({ self.someString }, { self.someString = valueParser($0)! }),
//            "number": ({ self.someNumber as Any }, { self.someNumber = valueParser($0)! }),
////            "a_bar": ({ self.optBar as Any }, { self.optBar = transformerParser($0) }),
//            "a_bar": ({ self.optBar as Any }, { self.optBar = barParser($0) }),
//            "enum_color": ({ self.color as Any }, { self.color = Color(rawValue: $0 as! String)! })
//        ]
//    }
    
    var mappings: [String : Map] {
        return [
            "a_string": Map(from: { self.someString }, to: { self.someString = valueParser($0)! }),
            "number": Map(from: { self.someNumber }, to: { self.someNumber = valueParser($0)! }),
            "a_bar": Map(from: { self.optBar }, to: { self.optBar = jsonObjectParser($0) }),
            "enum_color": Map(from: { self.color }, to: { self.color = Color(rawValue: $0 as! String)! }),
            "bar_array": Map(from: { self.arr }, to: { self.arr = jsonArrayParser($0) })
        ]
    }
}

class Map {
    typealias T = Any
    var from: () -> T?
    var to: (Any?) -> Void
    
    init(from: () -> T?, to: (Any?) -> Void) {
        self.from = from
        self.to = to
    }
}

func jsonObjectParser<T: JSONSerializable>(input: Any?) -> T? {
    var result: T? = nil
    
    if let t = input as? T {
        result = t
    } else if let dictionary = input as? [String : Any] {
        result = T(dictionary: dictionary)
    }
    
    return result
}

func jsonArrayParser<T: JSONSerializable>(input: Any?) -> [T]? {
    var result: [T]? = nil
    
    if let t = input as? [T] {
        result = t
    } else if let array = input as? [[String : Any]] {
        result = [T]()
        for dict in array {
            let t = T(dictionary: dict)
            result!.append(t)
        }
    }
    
    return result
}

func jsonObjectMaker<T: JSONSerializable>(object: T) -> [String : Any] {
    var result = [String : Any]()
    
    for (k, v) in object.mappings {
        let value = v.from()
        
        if let json = value as? JSONType {
            result[k] = json.toJSON()
        } else if let ser = value as? JSONSerializable {
            result[k] = ser.toDictionary()
        }
    }
    
    return result
}

func valueParser<T>(input: Any?) -> T? {
    var result: T? = nil
    
    if let t = input as? T {
        result = t
    }
    
    return result
}


//func jsonValueParser<T>(input: Any) -> T? {
//    return input as? T
//}

//func transformerParser<T: BaseClass>(input: Any?) -> T? {
//    return input as? T ?? jsonObjectParser(input)//Bar(dictionary: input as? [String : Any])
//}

func barParser(input: Any?) -> Bar? {
    return input as? Bar ?? jsonObjectParser(input)//Bar(dictionary: input as? [String : Any])
}

//func intParser(input: Any?) -> Int? {
//    return input as? Int
//}

let barDict: [String : Any] = ["third_boolean": true, "four_double": 99.987]
let dict: [String : Any] = ["a_string": "happpyyyy!", "number": 13, "a_bar": barDict, "enum_color": "B"]
let f = Foo(dictionary: dict)
let s = f.someString
let n = f.someNumber
let c = f.color
let b = f.optBar
let th = b?.three
let four = b?.four

let d = f.toDictionary()


