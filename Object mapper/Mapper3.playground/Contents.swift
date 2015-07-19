//: Playground - noun: a place where people can play

enum Color: String {
    case Red = "R"
    case Green = "G"
    case Blue = "B"
}

protocol Mappable {
    typealias T
    
    var mappings: [String : T] { get }
}

protocol JSONType { }

extension Int: JSONType { }
extension Double: JSONType { }
extension String: JSONType { }
extension Bool: JSONType { }
extension Dictionary: JSONType { }
extension Array: JSONType { }
extension Optional: JSONType { }

protocol JSONSerializable: Mappable {
    init(jsonType: JSONType)
    func toDictionary() -> [String : Any]
}

func defaultInit<T: JSONSerializable>(object: T, #jsonType: JSONType) {
    if let dictionary = jsonType as? [String : JSONType] {

        
    }
}

class MyClass: Mappable, JSONSerializable {
    var str = "String"
    var num = 10
    var dbl = 13.3
    var flag = false
    
    // Mappable
    typealias T = Any.Type
    var mappings: [String : T] {
        return [
            "key_str": String.self,
            "key_num": Int.self,
            "key_dbl": Double.self,
            "key_flag": Bool.self
        ]
    }
    
    // JSONSerializable
    required init(jsonType: JSONType) {
        defaultInit(self, jsonType: jsonType)
    }
    
    func toDictionary() -> [String : Any] {
        return [:]
    }
}

//let m = MyClass(jsonType: 10)

let x = 10
let dead = "I am not dead if I am here."

typealias JSONObjectMetaType = JSONSerializable.Type
typealias JSONMetaType = JSONType.Type
typealias T = Any.Type
let typeArr: [T] = [String.self, Int.self, MyClass.self]

for t in typeArr {
    if let jt 
    println(t)
}



//extension String {
//    static func parse(any: Any?) -> String? {
//        return any as? String
//    }
//}
//
//protocol Mappable {
//    var mappings: [String : (() -> Any?, (Any?) -> Void)] { get }
//}
//
//protocol JSONSerializable: Mappable {
//    init?(dictionary: [String : Any?]?)
//    func toDictionary() -> [String : Any]
//}
//
//func defaultInitialization<T: JSONSerializable>(object: T, #dictionary: [String : Any?]) {
//    for (key, value) in dictionary {
//        if let m = object.mappings[key] {
//            let f = m.1
//            f(value)
//        }
//    }
//}
//
//class Bar: Mappable, JSONSerializable {
//    var three = false
//    var four = 0.1
//    
//    
//    init() {
//        
//    }
//    
//    required init?(dictionary: [String : Any?]?) {
//        if let d = dictionary {
//            defaultInitialization(self, dictionary: d)
//        } else {
//            return nil
//        }
//    }
//    
//    func toDictionary() -> [String : Any] {
//        return [:]
//    }
//    
//    var mappings: [String : (() -> Any?, (Any?) -> Void)] {
//        return [
//            "third_boolean": ({ self.three as Any }, { self.three = $0 as! Bool }),
//            "four_double": ({ self.four as Any } , { self.four = $0 as! Double })
//        ]
//    }
//}
//
//class Foo: Mappable, JSONSerializable {
//    var someString = "string"
//    var someNumber = 10
//    var optBar: Bar? = Bar()
//    var color: Color = .Red
//    
//    init() {
//        
//    }
//    
//    required init?(dictionary: [String : Any?]?) {
//        if let d = dictionary {
//            defaultInitialization(self, dictionary: d)
//        } else {
//            return nil
//        }
//    }
//    
//    func toDictionary() -> [String : Any] {
//        var result = [String : Any]()
//        
//        for (k, v) in mappings {
//            result[k] = v.0() // Do transform to JSON and shit in here
//        }
//        
//        return result
//    }
//    
//    var mappings: [String : (() -> Any?, (Any?) -> Void)] {
//        return [
//            "a_string": ({ self.someString as Any }, { self.someString = $0 as! String }),
//            "number": ({ self.someNumber as Any }, { self.someNumber = $0 as! Int }),
//            "a_bar": ({ self.optBar as Any }, { self.optBar = barParser($0) }),
//            "enum_color": ({ self.color as Any }, { self.color = Color(rawValue: $0 as! String)! })
//        ]
//    }
//}
//
//func barParser(input: Any?) -> Bar? {
//    return input as? Bar ?? Bar(dictionary: input as? [String : Any?])
//}
//
//func intParser(input: Any?) -> Int? {
//    return input as? Int
//}
//
//let barDict: [String : Any?] = ["third_boolean": true, "four_double": 99.987]
//let dict: [String : Any?] = ["a_string": "sad!", "number": 13, "a_bar": barDict, "enum_color": "B"]
//let f = Foo(dictionary: dict)
//let s = f?.someString
//let n = f?.someNumber
//let c = f?.color
//let b = f?.optBar
//let th = b?.three
//let four = b?.four
//
//let d = f?.toDictionary()
