//
//  StringExtension.swift
//  forest
//
//  Created by olderor on 23.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import Foundation


class MyString : NSObject, Comparable {
    
    private var value: String
    
    init(value: String) {
        self.value = value
    }
    
    static private func getEqualLengthStrings(first: String, second: String) -> (String, String) {
        var left = first
        var right = second
        while left.characters.count < right.characters.count {
            left = "0" + left
        }
        while right.characters.count < left.characters.count {
            right = "0" + right
        }
        return (left, right)
    }
    
    //MARK: - Comparable
    
    static func <(lhs: MyString, rhs: MyString) -> Bool {
        let strings = getEqualLengthStrings(first: lhs.value, second: rhs.value)
        return strings.0 < strings.1
    }
    
    static func <=(lhs: MyString, rhs: MyString) -> Bool {
        let strings = getEqualLengthStrings(first: lhs.value, second: rhs.value)
        return strings.0 <= strings.1
    }
    
    static func >=(lhs: MyString, rhs: MyString) -> Bool {
        let strings = getEqualLengthStrings(first: lhs.value, second: rhs.value)
        return strings.0 >= strings.1
    }
    
    static func >(lhs: MyString, rhs: MyString) -> Bool {
        let strings = getEqualLengthStrings(first: lhs.value, second: rhs.value)
        return strings.0 > strings.1
    }
    
    //MARK: - Equatable
    
    static func ==(lhs: MyString, rhs: MyString) -> Bool {
        let strings = getEqualLengthStrings(first: lhs.value, second: rhs.value)
        return strings.0 == strings.1
    }
    
    // MARK:- Description
    
    override var description: String {
        return value
    }
    
    override var debugDescription: String {
        return value
    }
}
