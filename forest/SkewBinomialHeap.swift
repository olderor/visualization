//
//  SkewBinomialHeap.swift
//  forest
//
//  Created by olderor on 15.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import Foundation

class HeapNode<Element> {
    public var order = 0
    public var childrens = Deque<HeapNode>()
    public var singletons = Deque<HeapNode>()
    public var value: Element
    
    init(value: Element) {
        self.value = value
    }
    
    init (value: Element, order: Int) {
        self.value = value
        self.order = order
    }
}

class SkewBinomialHeap<Element: Comparable> {
    
    private var trees = Deque<HeapNode<Element>>()
    private var elementsCount = 0
    
    init() {
        
    }
    
    var first: Element? {
        if isEmpty {
            return nil
        }
        return trees[findMinIndex()].value
    }
    
    private func cloneTree(tree: HeapNode<Element>) -> HeapNode<Element> {
        
        let result = HeapNode(value: tree.value, order: tree.order)
        
        for child in tree.childrens {
            result.childrens.append(child)
        }
        
        for singleton in tree.singletons {
            result.singletons.append(singleton)
        }
        
        return result
    }
    
    init(other: SkewBinomialHeap<Element>) {
        for tree in other.trees {
            trees.append(cloneTree(tree: tree))
        }
        elementsCount = other.elementsCount
    }
    
    var isEmpty: Bool {
        return size == 0
    }
    
    var size: Int {
        return trees.count
    }
    
    private func merge(
        first: HeapNode<Element>?,
        second: HeapNode<Element>?) -> HeapNode<Element>? {
        
        if first == nil {
            return second
        }
        if second == nil {
            return first
        }
        
        var first = first!
        var second = second!
        if second.value < first.value {
            swap(&first, &second)
        }
        first.childrens.append(second)
        first.order += 1
        return first
    }
    
    private func insertSingleton(singleton: HeapNode<Element>) {
        if !(trees.count >= 2 && trees[0].order == trees[1].order) {
            trees.prepend(singleton)
            return
        }
        let first = trees.removeFirst()
        let second = trees.removeFirst()
        
        let newTree = merge(first: first, second: second)!
        if singleton.value < newTree.value {
            swap(&singleton.value, &newTree.value)
        }
        
        newTree.singletons.append(singleton)
        trees.prepend(newTree)
    }
    
    func push(element: Element) {
        insertSingleton(singleton: HeapNode(value: element))
        elementsCount += 1
    }
    
    private func findMinIndex() -> Int {
        var index = 0
        for i in 1..<trees.count {
            if trees[i].value < trees[index].value {
                index = i
            }
        }
        return index
    }
    
    private func mergeHeaps(
        first: Deque<HeapNode<Element>>,
        second: Deque<HeapNode<Element>>) -> Deque<HeapNode<Element>> {
        var first = first
        var second = second
        var all = Deque<HeapNode<Element>>()
        
        var result = Deque<HeapNode<Element>>()
        
        while !first.isEmpty && !second.isEmpty {
            if first.first!.order < second.first!.order {
                all.append(first.removeFirst())
            } else {
                all.append(second.removeFirst())
            }
        }
        
        while !first.isEmpty {
            all.append(first.removeFirst())
        }
        while !second.isEmpty {
            all.append(second.removeFirst())
        }
        
        while !all.isEmpty {
            var treesWithSameOrder = Deque<HeapNode<Element>>()
            treesWithSameOrder.append(all.removeFirst())
            
            while !all.isEmpty &&
                all.first!.order == treesWithSameOrder.first!.order {
                    treesWithSameOrder.append(all.removeFirst())
            }
            
            if treesWithSameOrder.count % 2 == 1 {
                result.append(treesWithSameOrder.removeFirst())
            }
            
            while !treesWithSameOrder.isEmpty {
                let firstTree = treesWithSameOrder.removeFirst()
                let secondTree = treesWithSameOrder.removeFirst()
                all.prepend(merge(first: firstTree, second: secondTree)!)
            }
        }
        
        return result
    }
    
    func pop() {
        
        if isEmpty {
            return
        }
        
        let index = findMinIndex()
        let treeToRemove = trees[index]
        trees.remove(at: index)
        trees = mergeHeaps(first: trees, second: treeToRemove.childrens)
        
        while !treeToRemove.singletons.isEmpty {
            insertSingleton(singleton: treeToRemove.singletons.first!)
            let _ = treeToRemove.singletons.removeFirst()
        }
        
        if trees.count == 0 {
            
        }
        
        elementsCount -= 1
    }
    
    func merge(other: SkewBinomialHeap<Element>) {
        trees = mergeHeaps(first: trees, second: other.trees)
        elementsCount += other.elementsCount
        other.elementsCount = 0
    }
    
}
