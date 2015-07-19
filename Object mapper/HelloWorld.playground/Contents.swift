//: Playground - noun: a place where people can play

import UIKit
import Foundation

func printSomeBooty(name: String) {
    println("Hello, \(name)!")
}

printSomeBooty("Carmen")

printSomeBooty("Doug")

printSomeBooty("Stefan")

printSomeBooty("Sophie")

enum Gender: Int {
    case Female
    case Male
}

class Person {
    var firstName: String = ""
    var middleName: String = ""
    var lastName: String = ""
    var age: Int = Int.max
    var gender: Gender = .Female
    
    func getFullName() -> String {
        return "\(firstName) \(middleName) \(lastName)"
    }
}

var carmen = Person()
carmen.firstName = "Carmen"
carmen.middleName = "Anna"
carmen.lastName = "Nesbitt"
carmen.age = 24
carmen.gender = .Female

var stefan = Person()
stefan.firstName = "Stefan"
stefan.middleName = "Andrew"
stefan.lastName = "Arambasich"

var randomPerson = stefan

println(randomPerson.getFullName())

