//
//  SkewBinomialHeapAnimation.swift
//  forest
//
//  Created by olderor on 15.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit
import Foundation

let nodeOffset: CGFloat = 10
let treeOffset: CGFloat = 25
let nodeSize: CGFloat = 50
let lineWidth: CGFloat = 2
let fontSize: CGFloat = 20

var nodeSizeDifference: CGFloat {
    return nodeOffset + nodeSize
}
var treeSizeDifference: CGFloat {
    return treeOffset + nodeSize
}

class Node {
    
    var mainScrollView: UIScrollView!
    var mainView: UIView!
    var singletonsStackView: UIView!
    
    
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
    
    func moveTo(x: CGFloat, y: CGFloat) {
        move(difX: frame.origin.x - x, difY: frame.origin.y - y)
    }
    
    func move(difX: CGFloat, difY: CGFloat) {
        frame.origin.x = frame.origin.x + difX
        frame.origin.y = frame.origin.y + difY
        
        AnimationManager.addAnimation(animation: {
            self.view.frame.origin.x = self.view.frame.origin.x + difX
            self.view.frame.origin.y = self.view.frame.origin.y + difY
            
            self.mainView.frame.size.width = max(self.mainView.frame.size.width, self.view.frame.origin.x + self.view.frame.size.width + treeOffset)
            self.mainView.frame.size.height = max(self.mainView.frame.size.height, self.view.frame.origin.y + self.view.frame.size.height + treeOffset)
            self.mainScrollView.contentSize = CGSize(width: self.mainView.frame.size.width, height: self.mainView.frame.size.height)
        }, completion: nil, type: .animation)
    }
    
    func getMovesToBlock(x: CGFloat, y: CGFloat) -> () -> Void {
        frame.origin.x = x
        frame.origin.y = y
        
        return {
            self.view.frame.origin.x = x
            self.view.frame.origin.y = y
            
            self.mainView.frame.size.width = max(self.mainView.frame.size.width, self.view.frame.origin.x + self.view.frame.size.width + treeOffset)
            self.mainView.frame.size.height = max(self.mainView.frame.size.height, self.view.frame.origin.y + self.view.frame.size.height + treeOffset)
            self.mainScrollView.contentSize = CGSize(width: self.mainView.frame.size.width, height: self.mainView.frame.size.height)
        }
    }
    
    func getMovesBlock(difX: CGFloat, difY: CGFloat) -> () -> Void {
        frame.origin.x = frame.origin.x + difX
        frame.origin.y = frame.origin.y + difY
        
        return {
            self.view.frame.origin.x = self.view.frame.origin.x + difX
            self.view.frame.origin.y = self.view.frame.origin.y + difY
            
            self.mainView.frame.size.width = max(self.mainView.frame.size.width, self.view.frame.origin.x + self.view.frame.size.width + treeOffset)
            self.mainView.frame.size.height = max(self.mainView.frame.size.height, self.view.frame.origin.y + self.view.frame.size.height + treeOffset)
            self.mainScrollView.contentSize = CGSize(width: self.mainView.frame.size.width, height: self.mainView.frame.size.height)
        }
    }
    
    func createNode(text: String) {
        frame = CGRect(x: nodeOffset, y: nodeOffset, width: nodeSize, height: nodeSize)
        root = CGPoint(x: nodeSize / 2, y: nodeSize / 2)
        view = UIView(frame: frame)
        label = UILabel(frame: CGRect(x: 0, y: 0, width: nodeSize, height: nodeSize))
        label.text = text
        label.font = label.font.withSize(fontSize)
        label.textAlignment = .center
        label.layer.backgroundColor = UIColor.green.cgColor
        label.layer.cornerRadius = nodeSize / 2
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = lineWidth
        view.addSubview(label)
        
        AnimationManager.addAnimation(animation: {
            self.mainView.addSubview(self.view)
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
            
            let newView = UIView(frame: newFrame)
            newView.addSubview(self.view)
            newView.addSubview(node.view)
            self.mainView.addSubview(newView)
            
            self.mainView.frame.size.width = max(self.mainView.frame.size.width, newView.frame.origin.x + newView.frame.size.width + treeOffset)
            self.mainView.frame.size.height = max(self.mainView.frame.size.height, newView.frame.origin.y + newView.frame.size.height + treeOffset)
            self.mainScrollView.contentSize = CGSize(width: self.mainView.frame.size.width, height: self.mainView.frame.size.height)
            
            self.view = newView
            
            self.connectNodes(from: CGPoint(x: self.root.x, y: self.root.y), to: CGPoint(x: self.root.x, y: self.root.y + nodeSizeDifference))
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
            
            let width = self.view.frame.size.width
            
            let newView = UIView(frame: newFrame)
            newView.addSubview(self.view)
            newView.addSubview(node.view)
            self.mainView.addSubview(newView)
            
            self.mainView.frame.size.width = max(self.mainView.frame.size.width, newView.frame.origin.x + newView.frame.size.width + treeOffset)
            self.mainView.frame.size.height = max(self.mainView.frame.size.height, newView.frame.origin.y + newView.frame.size.height + treeOffset)
            self.mainScrollView.contentSize = CGSize(width: self.mainView.frame.size.width, height: self.mainView.frame.size.height)
            
            self.view = newView
            
            self.connectNodes(from: CGPoint(x: self.root.x, y: self.root.y), to: CGPoint(x: node.root.x + width + nodeOffset, y: node.root.y + nodeSizeDifference), isDashed: true)
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
            
            let newView = UIView(frame: newFrame)
            newView.addSubview(self.view)
            newView.addSubview(node.view)
            self.mainView.addSubview(newView)
            
            self.mainView.frame.size.width = max(self.mainView.frame.size.width, newView.frame.origin.x + newView.frame.size.width + treeOffset)
            self.mainView.frame.size.height = max(self.mainView.frame.size.height, newView.frame.origin.y + newView.frame.size.height + treeOffset)
            self.mainScrollView.contentSize = CGSize(width: self.mainView.frame.size.width, height: self.mainView.frame.size.height)
            
            self.view = newView
            
            
            self.connectNodes(from: CGPoint(x: self.root.x, y: self.root.y), to: CGPoint(x: node.root.x, y: node.root.y + nodeSizeDifference))
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
    
    func createNode(mainScrollView: UIScrollView, mainView: UIView, singletonsStackView: UIView) {
        self.mainScrollView = mainScrollView
        self.mainView = mainView
        self.singletonsStackView = singletonsStackView
        createNode(text: String(describing: value))
    }
    
    func removeRoot() {
        
        AnimationManager.addAnimation(animation: {
            
            func removeRootInView(view: UIView, x: CGFloat, y: CGFloat) {
                view.removeFromSuperview()
                if view.isKind(of: UILabel.self) || view.subviews.count == 0 {
                    return
                }
                let subview = view.subviews[0]
                removeRootInView(view: subview, x: x + subview.frame.origin.x, y: y + subview.frame.origin.y)
                for view in subview.subviews {
                    view.removeFromSuperview()
                    view.frame.origin.x += x
                    view.frame.origin.y += y - nodeOffset
                    self.mainView.addSubview(view)
                }
                for view in view.subviews {
                    view.removeFromSuperview()
                    view.frame.origin.x += x
                    view.frame.origin.y += y - nodeOffset
                    self.mainView.addSubview(view)
                }
            }
            
            removeRootInView(view: self.view, x: self.view.frame.origin.x, y: self.view.frame.origin.y)
        }, completion: nil, type: .none)
    }
}

class SkewBinomialHeapAnimation<Element: Comparable> {
    
    var mainScrollView: UIScrollView!
    var mainView: UIView!
    var singletonsStackView: UIView!
    
    private var trees = Deque<HeapNodeAnimation<Element>>()
    private var elementsCount = 0
    
    
    init (mainScrollView: UIScrollView, mainView: UIView, singletonsStackView: UIView) {
        self.mainScrollView = mainScrollView
        self.mainView = mainView
        self.singletonsStackView = singletonsStackView
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
        second: HeapNodeAnimation<Element>?, enabledMoving: Bool = true) -> HeapNodeAnimation<Element>? {
        
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
            if enabledMoving {
                moveTrees(difX: -treeSizeDifference, difY: 0)
            }
        } else {
            second.move(difX: nodeSizeDifference - treeSizeDifference, difY: 0)
            first.deselect()
            second.deselect()
            second.appendChild(node: first)
            second.pulse()
            if enabledMoving {
                moveTrees(difX: nodeSizeDifference - treeSizeDifference, difY: 0)
            }
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
        singleton.createNode(mainScrollView: mainScrollView, mainView: mainView, singletonsStackView: singletonsStackView)
        
        
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
    
    private func reshowTrees(trees: Deque<HeapNodeAnimation<Element>>) {
        var curX = nodeOffset
        var animations = [() -> Void]()
        
        for tree in trees {
            animations.append(tree.getMovesToBlock(x: curX, y: nodeOffset))
            curX += tree.frame.size.width + treeOffset
        }
        
        AnimationManager.addAnimation(animation: {
            for animation in animations {
                animation()
            }
        }, completion: nil, type: .animation)
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
        
        reshowTrees(trees: result)
        
        while !result.isEmpty {
            var treesWithSameOrder = Deque<HeapNodeAnimation<Element>>()
            let tree = result.removeFirst()
            tree.select()
            treesWithSameOrder.append(tree)
            
            while !result.isEmpty &&
                result.first!.order == treesWithSameOrder.first!.order {
                    let tree = result.removeFirst()
                    tree.select()
                    treesWithSameOrder.append(tree)
            }
            
            if treesWithSameOrder.count % 2 == 1 {
                let tree = treesWithSameOrder.removeFirst()
                tree.deselect()
                first.append(tree)
            }
            
            while !treesWithSameOrder.isEmpty {
                let firstTree = treesWithSameOrder.removeFirst()
                let secondTree = treesWithSameOrder.removeFirst()
                let difX = firstTree.order == 0 ? -treeSizeDifference : nodeOffset - treeOffset
                
                var animations = [() -> Void]()
                
                for tree in treesWithSameOrder {
                    animations.append(tree.getMovesBlock(difX: difX, difY: 0))
                }
                for tree in result {
                    animations.append(tree.getMovesBlock(difX: difX, difY: 0))
                }
                
                result.prepend(merge(first: firstTree, second: secondTree, enabledMoving: false)!)
                
                AnimationManager.addAnimation(animation: {
                    for animation in animations {
                        animation()
                    }
                }, completion: nil, type: .animation)
            }
        }
    }
    
    private func moveSingletons(singletons: Deque<HeapNodeAnimation<Element>>) {
        
        
        var animations = [() -> Void]()
        var animationsAfter = [() -> Void]()
        
        animationsAfter.append() {
            self.singletonsStackView.frame.origin.y -= nodeOffset * 2 + nodeSize
            self.singletonsStackView.frame.size.height = nodeOffset * 2 + nodeSize
            self.mainScrollView.frame.size.height -= nodeOffset * 2 + nodeSize
            self.singletonsStackView.layer.borderWidth = lineWidth
            self.singletonsStackView.layer.borderColor = UIColor.green.cgColor
        }
        
        var x: CGFloat = nodeOffset
        for singleton in singletons {
            
            let moveToX = x
            animations.append() {
                singleton.view.frame.origin.x = moveToX
                singleton.view.frame.origin.y = self.singletonsStackView.frame.origin.y + nodeOffset
            }
            
            singleton.frame.origin.x = moveToX
            singleton.frame.origin.y = nodeOffset
            
            
            animationsAfter.append() {
                singleton.view.removeFromSuperview()
                singleton.view.frame.origin.y = nodeOffset
                self.singletonsStackView.addSubview(singleton.view)
            }
            
            x += nodeSize + nodeOffset
        }
        
        AnimationManager.addAnimation(animation: {
            for animation in animations {
                animation()
            }
        }, completion: nil, type: .animation)
        
        AnimationManager.addAnimation(animation: {
            for animation in animationsAfter {
                animation()
            }
        }, completion: nil, type: .animation)
    }
    
    func pop() {
        
        if isEmpty {
            return
        }
        
        let index = findMinIndex()
        let treeToRemove = trees[index]
        treeToRemove.changeBackground(color: .red)
        treeToRemove.changeBackground(color: .white)
        treeToRemove.changeBackground(color: .red)
        treeToRemove.removeRoot()
        
        trees.remove(at: index)
        
        moveSingletons(singletons: treeToRemove.singletons)
        
        mergeHeaps(first: trees, second: treeToRemove.childrens)
        
        
        while !treeToRemove.singletons.isEmpty {
            let tree = treeToRemove.singletons.removeFirst()
            let treeView = tree.view!
            tree.changeBackground(color: .green)
            insertSingleton(singleton: HeapNodeAnimation<Element>(value: tree.value))
            
            AnimationManager.addAnimation(animation: {
                treeView.removeFromSuperview()
            }, completion: nil, type: .transition)
            
            var animations = [() -> Void]()
            for tree in treeToRemove.singletons {
                animations.append(tree.getMovesBlock(difX: -nodeSizeDifference, difY: 0))
            }
            AnimationManager.addAnimation(animation: {
                for animation in animations {
                    animation()
                }
            }, completion: nil, type: .animation)
            
        }
        
        AnimationManager.addAnimation(animation: {
            self.singletonsStackView.frame.origin.y += nodeSize + nodeOffset * 2
            self.singletonsStackView.frame.size.height = 0
            self.mainScrollView.frame.size.height += nodeSize + nodeOffset * 2
        }, completion: nil, type: .animation)
        
        elementsCount -= 1
    }
    
    func merge(other: SkewBinomialHeapAnimation<Element>) {
        mergeHeaps(first: trees, second: other.trees)
        elementsCount += other.elementsCount
        other.elementsCount = 0
    }
    
}
