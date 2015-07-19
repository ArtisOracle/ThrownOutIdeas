//: Playground - noun: a place where people can play

import UIKit

enum Color: String {
    case Red = "R"
    case Green = "G"
    case Blue = "B"
}

extension String {
    static func parse(any: Any?) -> String? {
        return any as? String
    }
}

protocol Mappable {
    var mappings: [String : (() -> Any?, (Any?) -> Void)] { get }
}

protocol JSONSerializable: Mappable {
    init?(dictionary: [String : Any?]?)
    func toDictionary() -> [String : Any]
}

extension JSONSerializable {
    func defaultInitialization(dictionary: [String : Any?]) {
        for (key, value) in dictionary {
            if let m = mappings[key] {
                let f = m.1
                f(value)
            }
        }
    }
}

class Bar: Mappable, JSONSerializable {
    var three = false
    var four = 0.1
    
    
    init() {
        
    }
    
    required init?(dictionary: [String : Any?]?) {
        if let d = dictionary {
            defaultInitialization(d)
        } else {
            return nil
        }
    }
    
    func toDictionary() -> [String : Any] {
        return [:]
    }
    
    var mappings: [String : (() -> Any?, (Any?) -> Void)] {
        return [
            "third_boolean": ({ self.three as Any }, { self.three = $0 as! Bool }),
            "four_double": ({ self.four as Any } , { self.four = $0 as! Double })
        ]
    }
}

class Foo: Mappable, JSONSerializable {
    var someString = "string"
    var someNumber = 10
    var optBar: Bar? = Bar()
    var color: Color = .Red
    
    init() {
        
    }
    
    required init?(dictionary: [String : Any?]?) {
        if let d = dictionary {
            defaultInitialization(d)
        } else {
            return nil
        }
    }
    
    func toDictionary() -> [String : Any] {
        var result = [String : Any]()
        
        for (k, v) in mappings {
            result[k] = v.0() // Do transform to JSON and shit in here
        }
        
        return result
    }
    
    var mappings: [String : (() -> Any?, (Any?) -> Void)] {
        return [
            "a_string": ({ self.someString as Any }, { self.someString = $0 as! String }),
            "number": ({ self.someNumber as Any }, { self.someNumber = $0 as! Int }),
            "a_bar": ({ self.optBar as Any }, { self.optBar = barParser($0) }),
            "enum_color": ({ self.color as Any }, { self.color = Color(rawValue: $0 as! String)! })
        ]
    }
}

func barParser(input: Any?) -> Bar? {
    return input as? Bar ?? Bar(dictionary: input as? [String : Any?])
}

func intParser(input: Any?) -> Int? {
    return input as? Int
}

let barDict: [String : Any?] = ["third_boolean": true, "four_double": 99.987]
let dict: [String : Any?] = ["a_string": "sad!", "number": 13, "a_bar": barDict, "enum_color": "B"]
let f = Foo(dictionary: dict)
let s = f?.someString
let n = f?.someNumber
let c = f?.color
let b = f?.optBar
let th = b?.three
let four = b?.four

let d = f?.toDictionary()



//
//infix operator <| { associativity left precedence 140 }
//
//func <| (lhs: Mapping, rhs: (Any) -> Void) -> Mapping {
//    lhs.setter = rhs
//    return lhs
//}
//
//infix operator => { associativity left precedence 141 }
//
//func => <U>(lhs: String, rhs: U) -> Mapping {
//    return Mapping(from: lhs, to: rhs)
//}
//
//protocol Mappable {
//    var mappings: [Mapping] { get }
//}
//
//protocol JSONType { }
//extension Int: JSONType { }
//extension Double: JSONType { }
//extension String: JSONType { }
//extension Bool: JSONType { }
//extension Dictionary: JSONType { }
//extension Array: JSONType { }
//extension Optional: JSONType { }
//
//func jsonserializable__init<T where T: Mappable, T: JSONTransformable>(target: T, json: JSONType) {
//    if let dictionary = json as? [String : JSONType] {
//        for (key, value) in dictionary {
//            if let m = target.mappings.filter({ $0.from == key }).first {
//                if let prop = m.to as? JSONTransformable {
//                    let PropertyType = prop.dynamicType
//                    m.to = PropertyType(json: value)
//                } else if let setter = m.setter {
//                    setter(value)
//                }
//            }
//        }
//    }
//}
//
//protocol JSONTransformable {
//    init!(json: JSONType)
//    func toJSON() -> JSONType
//    
////    init()
//}
//
//class Foo: Mappable, JSONTransformable {
//    var cat = "cat"
//    var dog = "dog"
//    
//    init() {
//        
//    }
//    
//    required init!(json: JSONType) {
//        jsonserializable__init(self, json: json)
//    }
//    
//    func toJSON() -> JSONType {
//        return 10
//    }
//    
//    var mappings: [Mapping] {
//        return [
//            "kitty" => cat <| { self.cat = $0 as! String }
//        ]
//    }
//}
//
//class RootClass: JSONTransformable, Mappable {
//    var str = "stri"
//    var num = 10.0
//    var opt: Foo? = nil
//    var boolean = false
//    
//    init() {
//        
//    }
//    
//    
//    // JSONSerializable
//    required init!(json: JSONType) {
//        jsonserializable__init(self, json: json)
//    }
//    
//    func toJSON() -> JSONType {
//        return 10
//    }
//    
//    
//    // Mappable
//    var mappings: [Mapping] {
//        return [
//            "boolean" => boolean <| { self.boolean = $0 as! Bool },
//            "some_Start" => str <| { self.str = $0 as! String },
//            "number" => num <| { self.num = $0 as! Double},
//            "optional" => opt
//        ]
//    }
//    
////    func update(str: String)(num: Double) -> RootClass {
////        self.str = str
////        self.num = numz
////        return self
////    }
//}
//
//let dict: [String : JSONType] = ["some_Start": "stringggg!", "boolean": true, "number": 15.3, "optional": ["m1ne": "MINE!!!"]]
//let rc = RootClass(json: dict)
//let s = rc.str
//let n = rc.num
//let b = rc.boolean
//let o = rc.opt
//
//class SubClass: RootClass {
//    var four = false
////    var five: Foo? = Foo()
//    
//    
//    // Mappable
//    override var mappings: [Mapping] {
//        return super.mappings + [
//            "fourth" => four,
////            "fifth" => five
//        ]
//    }
//}
//
//
//
//
//
//
//
//
//
//
//print("Hello!")
//
//
//
//
////var str = "Hello, playground"
////
////class Mapping<T, U> {
////    var from: T
////    var to: U
////    
////    init(from: T, to: U) {
////        self.from = from
////        self.to = to
////    }
////}
////
////protocol Mappable {
////    var mappings: [Mapping<String, () -> Any>] { get }
////}
////
////protocol JSONSerializable {
////    init!(dictionary: [NSObject : AnyObject])
////}
////
////infix operator => { associativity left precedence 140 }
////
////func =>(lhs: String, rhs: () -> Any) -> Mapping<String, () -> Any> {
////    return Mapping(from: lhs, to: rhs)
////}
////
////
////class RootClass: Mappable, JSONSerializable {
////    var str = "str"
////    var num = 10
////    
////    
////    // MARK: Mappable
////    var mappings: [Mapping<String, () -> Any>] {
////        return [
////            "string" => { self.str },
////            "number" => { self.num }
////        ]
////    }
////    
////    // MARK: Serializable
////    required init!(dictionary: [NSObject : AnyObject]) {
////        for (k, v) in dictionary {
////            if let sk = k as? String,
////              let f = mappings.filter({ $0.from == sk }).first {
////                let val = f.to()
////                if let str = val as? String {
////                    print(str)
////                }
////            }
////        }
////    }
////}
