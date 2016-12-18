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

let nodeOffset: CGFloat = 5
let treeOffset: CGFloat = 10
let size: CGFloat = 50
var nodeSizeDifference: CGFloat {
    return nodeOffset + size
}
var treeSizeDifference: CGFloat {
    return treeOffset + size
}

class Node {
    var view: UIView!
    var label: UILabel!
    
    var frame: CGRect!
    
    func pulse() {
        select()
        deselect()
    }
    
    func select() {
        changeBackground(color: .yellow)
    }
    
    func changeBackground(color: UIColor) {
        AnimationManager.addAnimation(animation: {
            print("changeBackground: " + self.label.text!)
            self.label.layer.backgroundColor = color.cgColor
            sleep(0)
        }, completion: nil, type: .animation)
    }
    
    func deselect() {
        changeBackground(color: .white)
    }
    
    func disapear() {
        AnimationManager.addAnimation(animation: {
            self.view.removeFromSuperview()
            sleep(0)
            }, completion: nil, type: .transition)
    }
    
    func move(difX: CGFloat, difY: CGFloat) {
        frame.origin.x = frame.origin.x + difX
        frame.origin.y = frame.origin.y + difY
        
        AnimationManager.addAnimation(animation: {
            self.view.frame.origin.x = self.view.frame.origin.x + difX
            self.view.frame.origin.y = self.view.frame.origin.y + difY
            sleep(0)
            }, completion: nil, type: .animation)
    }
    
    func getMovesBlock(difX: CGFloat, difY: CGFloat) -> () -> Void {
        frame.origin.x = frame.origin.x + difX
        frame.origin.y = frame.origin.y + difY
        
        return {
            self.view.frame.origin.x = self.view.frame.origin.x + difX
            self.view.frame.origin.y = self.view.frame.origin.y + difY
        }
    }
    
    func createNode(text: String) {
        frame = CGRect(x: nodeOffset, y: nodeOffset + 20, width: size, height: size)
        view = UIView(frame: frame)
        label = UILabel(frame: CGRect(x: 0, y: 0, width: size, height: size))
        label.text = text
        label.font = label.font.withSize(10)
        label.textAlignment = .center
        label.layer.backgroundColor = UIColor.green.cgColor
        label.layer.cornerRadius = size / 2
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 2
        view.addSubview(label)
        
        AnimationManager.addAnimation(animation: {
            print("insertSingleton: addSubview")
            
            mainView.addSubview(self.view)
            
            print("done")
            sleep(0)
        }, completion: nil, type: .transition)
    }
    
    func swapNodes(other: Node) {
        let difX = other.frame.origin.x - frame.origin.x
        let difY = other.frame.origin.y - frame.origin.y
        
        var animations = [() -> Void]()
        animations.append(getMovesBlock(difX: difX, difY: difY))
        animations.append(other.getMovesBlock(difX: -difX, difY: -difY))
        AnimationManager.addAnimation(animation: {
            print("swap trees: \(difX) \(difY)")
            for animation in animations {
                animation()
            }
            print("done")
            sleep(0)
        }, completion: nil, type: .animation)
    }
    
    func connectNodes(to: CGPoint) {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: view.frame.width - size / 2, y: size / 2))
        print("connecting: x: \(view.frame.width - size / 2), y: \(size / 2)")
        path.addQuadCurve(to: to, controlPoint: CGPoint(x: to.x, y: size / 2))
        print("connecting to x: \(to.x), y: \(to.y)")
        
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = nil
        layer.path = path.cgPath
        layer.lineWidth = 2
        layer.zPosition = -1
        view.layer.addSublayer(layer)
    }
    
    func appendToZeroOrderNode(node: Node) {
        frame.size.height += nodeSizeDifference
        
        AnimationManager.addAnimation(animation: {
            print("change view parent 0 order")
            self.view.removeFromSuperview()
            node.view.removeFromSuperview()
            
            let newFrame = CGRect(
                x: self.view.frame.origin.x,
                y: self.view.frame.origin.y,
                width: self.view.frame.size.width,
                height: self.view.frame.size.height + nodeSizeDifference)
            
            self.view.frame.origin.x = 0
            self.view.frame.origin.y = 0
            
            node.view.frame.origin.x = 0
            node.view.frame.origin.y = nodeSizeDifference
            
            let newView = UIView(frame: newFrame)
            newView.addSubview(self.view)
            newView.addSubview(node.view)
            mainView.addSubview(newView)
            self.view = newView
            let x = node.view.frame.origin.x + node.view.frame.size.width - size / 2
            let y = node.view.frame.origin.y + size / 2
            self.connectNodes(to: CGPoint(x: x, y: y))
            
            print("done")
            sleep(0)
            }, completion: nil, type: .none)
    }
    
    func appendNode(node: Node) {
        
        frame.size.width += node.frame.size.width + nodeOffset
        frame.origin.x -= node.frame.size.width + nodeOffset
        frame.size.height = node.frame.size.height + nodeSizeDifference
        
        AnimationManager.addAnimation(animation: {
            print("change view parent")
            self.view.removeFromSuperview()
            node.view.removeFromSuperview()
            
            let newFrame = CGRect(
                x: self.view.frame.origin.x - (node.frame.size.width + nodeOffset),
                y: self.view.frame.origin.y,
                width: self.view.frame.size.width + nodeOffset + node.view.frame.size.width,
                height: node.view.frame.size.height + nodeSizeDifference)
            
            self.view.frame.origin.x = node.view.frame.size.width + nodeOffset
            self.view.frame.origin.y = 0
            
            node.view.frame.origin.x = 0
            node.view.frame.origin.y = nodeSizeDifference
            
            let newView = UIView(frame: newFrame)
            newView.addSubview(self.view)
            newView.addSubview(node.view)
            mainView.addSubview(newView)
            self.view = newView
            let x = node.view.frame.origin.x + node.view.frame.size.width - size / 2
            let y = node.view.frame.origin.y + size / 2
            self.connectNodes(to: CGPoint(x: x, y: y))
            
            print("done")
            sleep(0)
        }, completion: nil, type: .none)
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
    
    func createNode() {
        createNode(text: String(describing: value))
    }
}

class SkewBinomialHeapAnimation<Element: Comparable> {
    
    private var trees = Deque<HeapNodeAnimation<Element>>()
    private var elementsCount = 0
    
    init() {
        
    }
    
    var first: Element? {
        let tree = trees[findMinIndex()]
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
        if second.value > first.value {
            swap(&first, &second)
            // swap frames.
            first.swapNodes(other: second)
        }
        
        second.childrens.append(first)
        second.order += 1
        
        first.move(difX: 0, difY: nodeSizeDifference)
        
        // special case for merging nodes with 0 order.
        if second.order == 1 {
            second.move(difX: -nodeSizeDifference + nodeSizeDifference - treeSizeDifference, difY: 0)
            
            first.deselect()
            second.deselect()
            second.appendToZeroOrderNode(node: first)
            second.pulse()
            moveTrees(difX: -treeSizeDifference, difY: 0)
        } else {
            second.move(difX: nodeSizeDifference - treeSizeDifference, difY: 0)
            first.deselect()
            second.deselect()
            second.appendNode(node: first)
            second.pulse()
            moveTrees(difX: nodeSizeDifference - treeSizeDifference, difY: 0)
        }
        
        return second
    }
    
    private func moveTrees(difX: CGFloat, difY: CGFloat) {
        var animations = [() -> Void]()
        for tree in self.trees {
            animations.append(tree.getMovesBlock(difX: difX, difY: difY))
        }
        AnimationManager.addAnimation(animation: {
            var counter = 0
            print("moveTrees: \(difX) \(difY)")
            for animation in animations {
                animation()
                counter += 1
            }
            print("done \(counter)")
            sleep(0)
        }, completion: nil, type: .animation)
    }
    
    
    private func insertSingleton(singleton: HeapNodeAnimation<Element>) {
        
        // move trees to get free space for new element.
        moveTrees(difX: treeSizeDifference, difY: 0)
        
        // add new element to the view.
        singleton.createNode()
        
        
        if !(trees.count >= 2 && trees[0].order == trees[1].order) {
            trees.prepend(singleton)
            
            // animation complete.
            singleton.deselect()
            return
        }
        
        
        
        let first = trees.removeFirst()
        let second = trees.removeFirst()
        
        // prepear for merging.
        first.select()
        second.select()
        
        let newTree = merge(first: first, second: second)!
        
        if singleton.value < newTree.value {
            swap(&singleton.value, &newTree.value)
            AnimationManager.addAnimation(animation: {
                swap(&singleton.label.text, &newTree.label.text)
                print("done")
                sleep(0)
            }, completion: nil, type: .animation)
        }
        
        newTree.singletons.append(singleton)
        
        // remove from view, now it's stored in the newTree.
        singleton.deselect()
        singleton.disapear()
        
        trees.prepend(newTree)
        moveTrees(difX: -treeSizeDifference, difY: 0)
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
                trees[index].deselect()
                index = i
                trees[i].deselect()
                trees[i].pulse()
                trees[i].select()
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
