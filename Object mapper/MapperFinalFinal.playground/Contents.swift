import Foundation

println("Hello, world!")

extension NSDate {
    class func parseDate(string: String) -> NSDate? {
        var date: NSDate?
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        date = formatter.dateFromString(string)
        
        return date
    }
}

if let d = NSDate.parseDate("2015-07-11T11:58:25-04:00") {
    print("\(d.timeIntervalSinceReferenceDate)")
}

//
//  JSONSerializable.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

protocol JSONType {
    init(json: AnyObject)
    func toJSON() -> AnyObject
}

protocol JSONSerializable: Mappable {
    init(dictionary: [String : AnyObject])
    func toDictionary() -> [String : AnyObject]
}

//
//  Map.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

class Map {
    typealias T = Any?
    var source: () -> T
    var to: (T) -> Void
    
    init(source: () -> T, to: (T) -> Void) {
        self.source = source
        self.to = to
    }
}

protocol Mappable {
    var mappings: [String : Map] { get }
}

//
//  ObjectMapper.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

func dateParser(input: Any?) -> NSDate? {
    var result: NSDate? = nil
    
    if let d = input as? NSDate {
        result = d
    } else if let str = input as? String {
        result = NSDate.parseDate(str)
    }
    
    return result
}

func defaultCoderInitialization<T where T: NSCoding, T: Mappable>(object: T, aDecoder coder: NSCoder) {
    for (key, map) in object.mappings {
        if let value: AnyObject = coder.decodeObjectForKey(key) {
            let f = map.to
            f(value)
        }
    }
}

func defaultEncoder<T where T: NSCoding, T: Mappable>(object: T, aCoder coder: NSCoder) {
    for (key, map) in object.mappings {
        let f = map.source
        if let o: AnyObject = f() as? AnyObject {
            coder.encodeObject(o, forKey: key)
        } else {
            coder.encodeObject(nil, forKey: key)
        }
    }
}

func defaultJSONSerializableInitialization<T: JSONSerializable>(object: T, #dictionary: [String : AnyObject]) {
    for (key, value) in dictionary {
        if let m = object.mappings[key] {
            let f = m.to
            f(value)
        }
    }
}

func enumerationParser<T: RawRepresentable>(rawValue: T.RawValue?) -> T? {
    if let r = rawValue {
        return T(rawValue: r)
    }
    
    return nil
}

func jsonObjectMaker<T: JSONSerializable>(object: T) -> [String : AnyObject] {
    var result = [String : AnyObject]()
    
    for (k, v) in object.mappings {
        let value = v.source()
        
        if let obj = value as? NSObject {
            result[k] = obj
        } else if let json = value as? JSONType {
            result[k] = json.toJSON()
        } else if let ser = value as? JSONSerializable {
            result[k] = ser.toDictionary()
        }
    }
    
    return result
}

//func jsonTypeParser<T: JSONType>(input: AnyObject?) -> T? {
//    var result: T? = nil
//
//    if let t = input as? T {
//        result = t
//    } else if let json: AnyObject = input as? AnyObject {
//        result = T(json: json)
//    }
//
//    return result
//}

func modelParser<T where T: JSONSerializable, T: NSCoding>(input: Any?) -> T? {
    var result: T? = nil
    
    if let t = input as? T {
        result = t
    } else if let dictionary = input as? [String : AnyObject] {
        result = T(dictionary: dictionary)
    } else if let aDecoder = input as? NSCoder {
        result = T(coder: aDecoder)
    }
    
    return result
}

func modelArrayParser<T: JSONSerializable>(input: Any?) -> [T]? {
    var result: [T]? = nil
    
    if let t = input as? [T] {
        result = t
    } else if let array = input as? [[String : AnyObject]] {
        result = [T]()
        for dict in array {
            let t = T(dictionary: dict)
            result!.append(t)
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

func valueArrayParser<T>(input: Any?) -> [T]? {
    var result: [T]? = nil
    
    if let t = input as? [T] {
        result = t
    }
    
    return result
}

// ***

enum AbstractSetting: Int, JSONType {
    case Toggle = 3
    case Switch = 6
    case Mutex = 99
    
    init(json: AnyObject) {
        self = .Switch
        if let num = json as? Int,
            let setting = AbstractSetting(rawValue: num) {
                self = setting
        }
    }
    
    func toJSON() -> AnyObject {
        return rawValue
    }
}

enum Color: String, JSONType {
    case Red = "R"
    case Green = "G"
    case Blue = "B"
    
    init(json: AnyObject) {
        self = .Red
        self = enumerationParser(json as? String) ?? self
    }
    
    func toJSON() -> AnyObject {
        return rawValue
    }
}

class Foo: JSONSerializable {
    var bar = "hello"
    
    var mappings: [String : Map] {
        return ["a_bar": Map(source: { self.bar }, to: { self.bar = valueParser($0) ?? self.bar })]
    }
    
    required init(dictionary: [String : AnyObject]) {
        defaultJSONSerializableInitialization(self, dictionary: dictionary)
    }
    
    func toDictionary() -> [String : AnyObject] {
        return jsonObjectMaker(self)
    }
    
}

class RootModel: JSONSerializable, NSCoding {
    var pk = 0
    var str = "String"
    var color: Color = .Red
    
    // Date
    var date = NSDate()
    
    // What about arrays?
    var arr = [String]()
    
    // Of objects?
    var arr2 = [Foo]()
    
    // Of enums?
    
    // How about lazys?
    private lazy var arr2Mappings: Map = { return Map(source: { self.arr2 }, to: { self.arr2 = modelArrayParser($0) ?? self.arr2 }) }()
    private lazy var pkMappings: Map = { return Map(source: { self.pk }, to: { self.pk = valueParser($0) ?? 0 }) }()
    private lazy var strMappings: Map = { return Map(source: { self.str }, to: { self.str = valueParser($0) ?? self.str }) }()
    private lazy var arrMappings: Map = { return Map(source: { self.arr }, to: { self.arr = valueArrayParser($0) ?? self.arr }) }()
//    private lazy var colorMappings: Map = { return Map(source: { self.color }, to: { self.color = Color(rawValue: $0 as? String ?? "") ?? self.color }) }()
    private lazy var colorMappings: Map = { return Map(source: { self.color }, to: { self.color = enumerationParser($0 as? String) ?? self.color }) }()
    private lazy var dateMappings: Map = { return Map(source: { self.date }, to: { self.date = dateParser($0) ?? self.date }) }()
    
    // MARK: - Mappable
    var mappings: [String : Map] {
        return [
            "fools": arr2Mappings,
            "id": pkMappings,
            "a_string": strMappings,
            "string_array": arrMappings,
            "preferred_color": colorMappings,
            "preferred_color": colorMappings,
            "date_time": dateMappings,
        ]
    }
    
    
    // MARK: - JSONSerializable
    required init(dictionary: [String : AnyObject]) {
        defaultJSONSerializableInitialization(self, dictionary: dictionary)
    }
    
    func toDictionary() -> [String : AnyObject] {
        return jsonObjectMaker(self)
    }
    
    // MARK: - NSCoding
    @objc required init(coder aDecoder: NSCoder) {
        defaultCoderInitialization(self, aDecoder: aDecoder)
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        defaultEncoder(self, aCoder: aCoder)
    }
}

class SettingsClass: JSONSerializable {
    var setting: AbstractSetting = .Switch
    
    
    var mappings: [String : Map] {
        return [
            "the_setting": Map(source: { self.setting }, to: { self.setting = enumerationParser($0 as? Int) ?? self.setting })
        ]
    }
    
    required init(dictionary: [String : AnyObject]) {
        //        for (key, value) in dictionary {
        //            if let m = mappings[key] {
        //                let f = m.to
        //                f(value)
        //            }
        //        }
        defaultJSONSerializableInitialization(self, dictionary: dictionary)
    }
    
    func toDictionary() -> [String : AnyObject] {
        return jsonObjectMaker(self)
    }
}

let stgs = SettingsClass(dictionary: ["the_setting": 99])
let st = stgs.setting.rawValue

// ***
let x = 10
println("Dead")

//: [[String : Any]]  // really dumb but this is required I guess. Wonder if that'll happen later, too
let arrayOfFoos: [[String : AnyObject]] = [["a_bar": "I am from a dictionary, not hard coded!"], ["a_bar": "I am from a dictionary, not hard coded! 2"], ["a_bar": "I am from a dictionary, not hard coded! 3"]]

let d: [String : AnyObject] = ["id": 13, "a_string": "Dictionary hi!", "a_double": 42.0, "a_boolean": true, "preferred_color": "G", "string_array": ["hello", "goodbye", "you suck"], "fools": arrayOfFoos, "date_time": "2015-07-11T09:18:03-04:00"]
let r = RootModel(dictionary: d)

let datetime = r.date

//let s = r.str
//
//let a = r.arr
//let c = r.color.rawValue
//
//var dictionary = r.toDictionary()
//
//let foos = r.arr2
//
//for f in foos {
//    print(f.bar)
//}
