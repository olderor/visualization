//
//  BrodalPriorityQueue.swift
//  forest
//
//  Created by olderor on 15.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import Foundation



class BPQNode<Element: Comparable> {
    var value: Element
    var queue: SkewBinomialHeap<BrodalPriorityQueue<Element>>
    
    init(value: Element) {
        self.value = value
        queue = SkewBinomialHeap<BrodalPriorityQueue<Element>>()
    }
    
    init(value: Element, queue: SkewBinomialHeap<BrodalPriorityQueue<Element>>) {
        self.value = value
        self.queue = queue
    }
}

class BrodalPriorityQueue<Element: Comparable> : Comparable {
    
    private var root: BPQNode<Element>?
    
    var isEmpty: Bool {
        return root == nil
    }
    
    //MARK: - Initialization
    
    init() {
        
    }
    
    init(value: Element) {
        root = BPQNode(value: value)
    }
    
    private init(value: Element,
                 queue: SkewBinomialHeap<BrodalPriorityQueue<Element>>) {
        root = BPQNode(value: value, queue: queue)
    }
    
    var first: Element? {
        if isEmpty {
            return nil
        }
        
        return root!.value
    }
    
    func merge(other: BrodalPriorityQueue) {
        if isEmpty {
            root = other.root
            return
        }
        if other.isEmpty {
            return
        }
        
        if root!.value < other.root!.value {
            root!.queue.push(element: other)
            return
        }
        
        let selfCopy = BrodalPriorityQueue<Element>(value: root!.value, queue: root!.queue)
        root!.queue = other.root!.queue
        root!.queue.push(element: selfCopy)
        root!.value = other.root!.value
    }
    
    func insert(element: Element) {
        merge(other: BrodalPriorityQueue(value: element))
    }
    
    func extractMin() -> Element? {
        if isEmpty {
            return nil
        }
        
        let minElement = root!.value
        if root!.queue.isEmpty {
            root = nil
            return minElement
        }
        let minBpq = root!.queue.first!
        root!.queue.pop()
        root!.queue.merge(other: minBpq.root!.queue)
        root!.value = minBpq.root!.value
        return minElement
    }
    
    //MARK: - Comparable
    
    static func <(lhs: BrodalPriorityQueue, rhs: BrodalPriorityQueue) -> Bool {
        if lhs.root == nil {
            return rhs.root != nil
        }
        if rhs.root == nil {
            return false
        }
        return lhs.root!.value < rhs.root!.value
    }
    
    static func <=(lhs: BrodalPriorityQueue, rhs: BrodalPriorityQueue) -> Bool {
        if lhs.root == nil {
            return true
        }
        if rhs.root == nil {
            return false
        }
        return lhs.root!.value <= rhs.root!.value
    }
    
    static func >=(lhs: BrodalPriorityQueue, rhs: BrodalPriorityQueue) -> Bool {
        if lhs.root == nil {
            return rhs.root == nil
        }
        if rhs.root == nil {
            return true
        }
        return lhs.root!.value >= rhs.root!.value
    }
    
    static func >(lhs: BrodalPriorityQueue, rhs: BrodalPriorityQueue) -> Bool {
        if lhs.root == nil {
            return false
        }
        if rhs.root == nil {
            return true
        }
        return lhs.root!.value > rhs.root!.value
    }
    
    //MARK: - Equatable
    
    static func ==(lhs: BrodalPriorityQueue, rhs: BrodalPriorityQueue) -> Bool {
        return lhs.root?.value == rhs.root?.value
    }
}
