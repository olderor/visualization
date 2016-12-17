//
//  SkewBinomialHeapAnimation.swift
//  forest
//
//  Created by olderor on 15.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit
import Foundation

var mainView: UIView!

class Node {
    var view: UILabel!
    var text: String!
    
    var frame: CGRect!
    
    func pulse() {
        if view == nil {
            return
        }
        AnimationManager.addAnimation(animation: {
            self.view.backgroundColor = UIColor.yellow
            sleep(0)
            }, completion: { (finished: Bool) -> Void in self.deselect() })
    }
    
    func select() {
        changeBackground(color: UIColor.yellow)
    }
    
    func changeBackground(color: UIColor) {
        if view == nil {
            return
        }
        AnimationManager.addAnimation(animation: {
            self.view.backgroundColor = color
            sleep(0)
            }, completion: nil)
    }
    
    func deselect() {
        changeBackground(color: UIColor.white)
    }
}

class HeapNodeAnimation<Element> : Node {
    public var order = 0
    public var childrens = Deque<HeapNodeAnimation>()
    public var singletons = Deque<HeapNodeAnimation>()
    public var value: Element
    
    init(value: Element) {
        self.value = value
    }
    
    init (value: Element, order: Int) {
        self.value = value
        self.order = order
    }
    
    func move(difX: CGFloat, difY: CGFloat) -> [() -> Void] {
        
        var moves = [() -> Void]()
        let newX = self.frame.origin.x + difX
        let newY = self.frame.origin.y + difY
        self.frame.origin.x = newX
        self.frame.origin.y = newY
        
        moves.append({
            print("move tree to \(newX) + \(newY) ")
            self.view.frame.origin.x = newX
            self.view.frame.origin.y = newY
            print("done")
        })
        
        for tree in childrens {
            moves.append(contentsOf: tree.move(difX: difX, difY: difY))
        }
        
        for tree in singletons {
            moves.append(contentsOf: tree.move(difX: difX, difY: difY))
        }
        
        return moves
    }
}

class SkewBinomialHeapAnimation<Element: Comparable> {
    
    private var trees = Deque<HeapNodeAnimation<Element>>()
    private var elementsCount = 0
    
    init() {
        
    }
    
    var first: Element? {
        let tree = trees[findMinIndex()]
        tree.pulse()
        return tree.value
    }
    
    private func cloneTree(tree: HeapNodeAnimation<Element>) -> HeapNodeAnimation<Element> {
        
        let result = HeapNodeAnimation(value: tree.value, order: tree.order)
        
        for child in tree.childrens {
            result.childrens.append(child)
        }
        
        for singleton in tree.singletons {
            result.singletons.append(singleton)
        }
        
        return result
    }
    
    init(other: SkewBinomialHeapAnimation<Element>) {
        for tree in other.trees {
            trees.append(cloneTree(tree: tree))
        }
        elementsCount = other.elementsCount
    }
    
    var isEmpty: Bool {
        return elementsCount == 0
    }
    
    var size: Int {
        return elementsCount
    }
    
    private func merge(
        first: HeapNodeAnimation<Element>?,
        second: HeapNodeAnimation<Element>?) -> HeapNodeAnimation<Element>? {
        
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
            
            let difX = second.frame.origin.x - first.frame.origin.x
            let difY = second.frame.origin.y - first.frame.origin.y
            var animations = second.move(difX: -difX, difY: -difY)
            animations.append(contentsOf: first.move(difX: difX, difY: difY))
            AnimationManager.addAnimation(animation: {
                print("merge: swap frames")
                for animation in animations {
                    animation()
                }
                print("done")
                sleep(0)
            }, completion: nil)
        }
        first.childrens.append(second)
        
        let animations = second.move(difX: -50, difY: 50)
        AnimationManager.addAnimation(animation: {
            print("merge: move second")
            for animation in animations {
                animation()
            }
            print("done")
            sleep(0)
        }, completion: nil)
        first.order += 1
        return first
    }
    
    private func moveTrees(difX: CGFloat, difY: CGFloat) -> [() -> Void] {
        var animations = [() -> Void]()
        for tree in self.trees {
            animations.append(contentsOf: tree.move(difX: difX, difY: difY))
        }
        return animations
    }
    
    
    private func insertSingleton(singleton: HeapNodeAnimation<Element>) {
        singleton.frame = CGRect(x: 25, y: 25, width: 40, height: 40)
        singleton.view = UILabel(frame: CGRect(x: 25, y: 25, width: 40, height: 40))
        singleton.view.text = String(describing: singleton.value)
        
        
        var animations = moveTrees(difX: 50, difY: 0)
        AnimationManager.addAnimation(animation: {
            var counter = 0
            print("insertSingleton: for tree in self.trees 50")
            for animation in animations {
                animation()
                counter += 1
            }
            print("done \(counter)")
            sleep(0)
        }, completion: nil)
        
        AnimationManager.addAnimation(animation: {
            print("insertSingleton: addSubview")
            singleton.view.backgroundColor = UIColor.green
            mainView.addSubview(singleton.view)
            print("done")
            sleep(0)
        }, completion: nil)
        
        if !(trees.count >= 2 && trees[0].order == trees[1].order) {
            
            trees.prepend(singleton)
            singleton.deselect()
            return
        }
        
        let first = trees.removeFirst()
        let second = trees.removeFirst()
        
        first.select()
        second.select()
        
        let newTree = merge(first: first, second: second)!
        
        
        animations = moveTrees(difX: -50, difY: 0)
        AnimationManager.addAnimation(animation: {
            print("insertSingleton: tree in self.trees -50")
            for animation in animations {
                animation()
            }
            print("done")
            sleep(0)
        }, completion: nil)
        
        
        if singleton.value < newTree.value {
            swap(&singleton.value, &newTree.value)
            AnimationManager.addAnimation(animation: {
                swap(&singleton.view.text, &newTree.view.text)
                print("done")
                sleep(0)
            }, completion: nil)
        }
        
        animations = singleton.move(difX: 0, difY: 50)
        AnimationManager.addAnimation(animation: {
            print("insertSingleton: y += 50")
            for animation in animations {
                animation()
            }
            print("done")
            sleep(0)
        }, completion: nil)
        newTree.singletons.append(singleton)
        /*
        animations = moveTrees(difX: 50, difY: 0)
        animations.append({
            newTree.view.frame = CGRect(x: 25, y: 25, width: 40, height: 40)
        })
        AnimationManager.addAnimation(animation: {
            print("insertSingleton: for tree in self.trees 50")
            print("and insertSingleton: newTree frame")
            for animation in animations {
                animation()
            }
            print("done")
            sleep(0)
        }, completion: nil)*/
        
        trees.prepend(newTree)
        first.deselect()
        second.deselect()
        singleton.deselect()
    }
    
    func push(element: Element) {
        insertSingleton(singleton: HeapNodeAnimation(value: element))
        elementsCount += 1
    }
    
    private func findMinIndex() -> Int {
        var index = 0
        trees[0].select()
        for i in 1..<trees.count {
            trees[i].select()
            if trees[i].value < trees[index].value {
                index = i
                trees[index].deselect()
                trees[i].deselect()
                trees[i].pulse()
            } else {
                trees[i].deselect()
            }
        }
        return index
    }
    
    private func mergeHeaps(
        first: Deque<HeapNodeAnimation<Element>>,
        second: Deque<HeapNodeAnimation<Element>>) {
        var first = first
        var second = second
        var result = Deque<HeapNodeAnimation<Element>>()
        while !first.isEmpty && !second.isEmpty {
            if first.first!.order < second.first!.order {
                result.append(first.removeFirst())
            } else {
                result.append(second.removeFirst())
            }
        }
        
        while !first.isEmpty {
            result.append(first.removeFirst())
        }
        while !second.isEmpty {
            result.append(second.removeFirst())
        }
        
        while !result.isEmpty {
            var treesWithSameOrder = Deque<HeapNodeAnimation<Element>>()
            treesWithSameOrder.append(result.removeFirst())
            
            while !result.isEmpty &&
                result.first!.order == treesWithSameOrder.first!.order {
                    treesWithSameOrder.append(result.removeFirst())
            }
            
            if treesWithSameOrder.count % 2 == 1 {
                first.append(treesWithSameOrder.removeFirst())
            }
            
            while !treesWithSameOrder.isEmpty {
                let firstTree = treesWithSameOrder.removeFirst()
                let secondTree = treesWithSameOrder.removeFirst()
                first.append(merge(first: firstTree, second: secondTree)!)
            }
        }
    }
    
    func pop() {
        
        if isEmpty {
            return
        }
        
        let index = findMinIndex()
        let treeToRemove = trees[index]
        trees.remove(at: index)
        mergeHeaps(first: trees, second: treeToRemove.childrens)
        
        while !treeToRemove.singletons.isEmpty {
            insertSingleton(singleton: treeToRemove.singletons.removeFirst())
        }
        
        elementsCount -= 1
    }
    
    func merge(other: SkewBinomialHeapAnimation<Element>) {
        mergeHeaps(first: trees, second: other.trees)
        elementsCount += other.elementsCount
        other.elementsCount = 0
    }
    
}
