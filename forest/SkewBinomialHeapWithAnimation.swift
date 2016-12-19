//
//  SkewBinomialHeapAnimation.swift
//  forest
//
//  Created by olderor on 15.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit
import Foundation

var mainScrollView: UIScrollView!
var mainView: UIView!

let nodeOffset: CGFloat = 10
let treeOffset: CGFloat = 25
let size: CGFloat = 50
let lineWidth: CGFloat = 2
let fontSize: CGFloat = 20

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
    
    private var root: CGPoint!
    
    func swapText(other: Node) {
        AnimationManager.addAnimation(animation: {
            self.label.layer.backgroundColor = UIColor.init(red: 0, green: 1, blue: 1, alpha: 1).cgColor
            other.label.layer.backgroundColor = UIColor.init(red: 0, green: 1, blue: 1, alpha: 1).cgColor
        }, completion: nil, type: .animation)
        
        AnimationManager.addAnimation(animation: {
            swap(&self.label.text, &other.label.text)
        }, completion: nil, type: .transition)
        
        AnimationManager.addAnimation(animation: {
            self.label.layer.backgroundColor = UIColor.yellow.cgColor
            other.label.layer.backgroundColor = UIColor.green.cgColor
        }, completion: nil, type: .animation)
    }
    
    func pulse() {
        select()
        deselect()
    }
    
    func select() {
        changeBackground(color: .yellow)
    }
    
    func changeBackground(color: UIColor) {
        AnimationManager.addAnimation(animation: {
            self.label.layer.backgroundColor = color.cgColor
        }, completion: nil, type: .animation)
    }
    
    func deselect() {
        changeBackground(color: .white)
    }
    
    func disapear() {
        AnimationManager.addAnimation(animation: {
            self.view.removeFromSuperview()
        }, completion: nil, type: .transition)
    }
    
    func move(difX: CGFloat, difY: CGFloat) {
        frame.origin.x = frame.origin.x + difX
        frame.origin.y = frame.origin.y + difY
        
        AnimationManager.addAnimation(animation: {
            self.view.frame.origin.x = self.view.frame.origin.x + difX
            self.view.frame.origin.y = self.view.frame.origin.y + difY
            
            mainView.frame.size.width = max(mainView.frame.size.width, self.view.frame.origin.x + self.view.frame.size.width + treeOffset)
            mainView.frame.size.height = max(mainView.frame.size.height, self.view.frame.origin.y + self.view.frame.size.height + treeOffset)
            mainScrollView.contentSize = CGSize(width: mainView.frame.size.width, height: mainView.frame.size.height)
        }, completion: nil, type: .animation)
    }
    
    func getMovesBlock(difX: CGFloat, difY: CGFloat) -> () -> Void {
        frame.origin.x = frame.origin.x + difX
        frame.origin.y = frame.origin.y + difY
        
        return {
            self.view.frame.origin.x = self.view.frame.origin.x + difX
            self.view.frame.origin.y = self.view.frame.origin.y + difY
            
            mainView.frame.size.width = max(mainView.frame.size.width, self.view.frame.origin.x + self.view.frame.size.width + treeOffset)
            mainView.frame.size.height = max(mainView.frame.size.height, self.view.frame.origin.y + self.view.frame.size.height + treeOffset)
            mainScrollView.contentSize = CGSize(width: mainView.frame.size.width, height: mainView.frame.size.height)
        }
    }
    
    func createNode(text: String) {
        frame = CGRect(x: nodeOffset, y: nodeOffset + 20, width: size, height: size)
        root = CGPoint(x: size / 2, y: size / 2)
        view = UIView(frame: frame)
        label = UILabel(frame: CGRect(x: 0, y: 0, width: size, height: size))
        label.text = text
        label.font = label.font.withSize(fontSize)
        label.textAlignment = .center
        label.layer.backgroundColor = UIColor.green.cgColor
        label.layer.cornerRadius = size / 2
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = lineWidth
        view.addSubview(label)
        
        AnimationManager.addAnimation(animation: {
            mainView.addSubview(self.view)
        }, completion: nil, type: .transition)
    }
    
    func swapNodes(other: Node) {
        
        let difX = other.frame.origin.x - frame.origin.x
        let difX2 = frame.origin.x + frame.size.width - other.frame.size.width - other.frame.origin.x
        let difY = other.frame.origin.y - frame.origin.y
        
        var animations = [() -> Void]()
        animations.append(getMovesBlock(difX: difX, difY: difY))
        animations.append(other.getMovesBlock(difX: difX2, difY: -difY))
        AnimationManager.addAnimation(animation: {
            for animation in animations {
                animation()
            }
        }, completion: nil, type: .animation)
        
    }
    
    func connectNodes(from: CGPoint, to: CGPoint, isDashed: Bool = false) {
        let path = UIBezierPath()
        
        path.move(to: from)
        path.addQuadCurve(to: to, controlPoint: CGPoint(x: to.x, y: from.y))
        
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = nil
        layer.path = path.cgPath
        layer.lineWidth = lineWidth
        layer.zPosition = -1
        if isDashed {
            layer.lineDashPattern = [0, NSNumber(value: Float(lineWidth * 4))]
            layer.lineCap = kCALineCapRound
        }
        
        view.layer.addSublayer(layer)
    }
    
    func appendToZeroOrderNode(node: Node) {
        frame.size.height += nodeSizeDifference
        
        AnimationManager.addAnimation(animation: {
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
            
            node.root.x = self.root.x
            node.root.y = self.root.y + nodeSizeDifference
            
            let newView = UIView(frame: newFrame)
            newView.addSubview(self.view)
            newView.addSubview(node.view)
            mainView.addSubview(newView)
            
            mainView.frame.size.width = max(mainView.frame.size.width, newView.frame.origin.x + newView.frame.size.width + treeOffset)
            mainView.frame.size.height = max(mainView.frame.size.height, newView.frame.origin.y + newView.frame.size.height + treeOffset)
            mainScrollView.contentSize = CGSize(width: mainView.frame.size.width, height: mainView.frame.size.height)
            
            self.view = newView
            
            self.connectNodes(from: CGPoint(x: self.root.x, y: self.root.y), to: CGPoint(x: node.root.x, y: node.root.y))
        }, completion: nil, type: .none)
    }
    
    func appendSingleton(node: Node) {
        frame.size.width += node.frame.size.width + nodeOffset
        AnimationManager.addAnimation(animation: {
            self.view.removeFromSuperview()
            node.view.removeFromSuperview()
            
            let newFrame = CGRect(
                x: self.view.frame.origin.x,
                y: self.view.frame.origin.y,
                width: self.view.frame.size.width + node.view.frame.size.width + nodeOffset,
                height: self.view.frame.size.height)
            
            self.view.frame.origin.x = 0
            self.view.frame.origin.y = 0
            
            node.view.frame.origin.x = self.view.frame.size.width + nodeOffset
            node.view.frame.origin.y = nodeSizeDifference
            
            node.root.x += self.view.frame.size.width + nodeOffset
            node.root.y += nodeSizeDifference
            
            let newView = UIView(frame: newFrame)
            newView.addSubview(self.view)
            newView.addSubview(node.view)
            mainView.addSubview(newView)
            
            mainView.frame.size.width = max(mainView.frame.size.width, newView.frame.origin.x + newView.frame.size.width + treeOffset)
            mainView.frame.size.height = max(mainView.frame.size.height, newView.frame.origin.y + newView.frame.size.height + treeOffset)
            mainScrollView.contentSize = CGSize(width: mainView.frame.size.width, height: mainView.frame.size.height)
            
            self.view = newView
            
            self.connectNodes(from: CGPoint(x: self.root.x, y: self.root.y), to: CGPoint(x: node.root.x, y: node.root.y), isDashed: true)
        }, completion: nil, type: .none)
    }
    
    func appendChild(node: Node) {
        
        frame.origin.x -= node.frame.size.width + nodeOffset
        frame.size.width += node.frame.size.width + nodeOffset
        frame.size.height = node.frame.size.height + nodeSizeDifference
        
        AnimationManager.addAnimation(animation: {
            self.view.removeFromSuperview()
            node.view.removeFromSuperview()
            
            let newFrame = CGRect(
                x: self.view.frame.origin.x - (node.view.frame.size.width + nodeOffset),
                y: self.view.frame.origin.y,
                width: self.view.frame.size.width + nodeOffset + node.view.frame.size.width,
                height: node.view.frame.size.height + nodeSizeDifference)
            
            self.view.frame.origin.x = node.view.frame.size.width + nodeOffset
            self.view.frame.origin.y = 0
            
            node.view.frame.origin.x = 0
            node.view.frame.origin.y = nodeSizeDifference
            self.root.x += node.view.frame.width + nodeOffset
            node.root.y += nodeSizeDifference
            
            let newView = UIView(frame: newFrame)
            newView.addSubview(self.view)
            newView.addSubview(node.view)
            mainView.addSubview(newView)
            
            mainView.frame.size.width = max(mainView.frame.size.width, newView.frame.origin.x + newView.frame.size.width + treeOffset)
            mainView.frame.size.height = max(mainView.frame.size.height, newView.frame.origin.y + newView.frame.size.height + treeOffset)
            mainScrollView.contentSize = CGSize(width: mainView.frame.size.width, height: mainView.frame.size.height)
            
            self.view = newView
            
            
            self.connectNodes(from: CGPoint(x: self.root.x, y: self.root.y), to: CGPoint(x: node.root.x, y: node.root.y))
        }, completion: nil, type: .none)
    }
    
    func removeRoot() {
        // to do
        /*
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
            }, completion: nil, type: .none)*/
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
            second.appendChild(node: first)
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
            for animation in animations {
                animation()
            }
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
            singleton.swapText(other: newTree)
        }
        
        newTree.singletons.append(singleton)
        
        newTree.swapNodes(other: singleton)
        singleton.move(difX: nodeSizeDifference - treeSizeDifference, difY: nodeSizeDifference)
        newTree.appendSingleton(node: singleton)
        singleton.deselect()
        newTree.deselect()
        
        moveTrees(difX: nodeSizeDifference - treeSizeDifference, difY: 0)
        trees.prepend(newTree)
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
        treeToRemove.changeBackground(color: .red)
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
