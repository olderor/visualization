//
//  BrodalPriorityQueueWithAnimation.swift
//  forest
//
//  Created by olderor on 20.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit





class BPQNodeAnimation<Element: Comparable> {
    var value: Element
    var queue: SkewBinomialHeapAnimation<BrodalPriorityQueueAnimation<Element>>
    
    var mainScrollView: UIScrollView!
    var mainView: UIView!
    var singletonsStackView: UIView!
    
    
    init(value: Element, mainScrollView: UIScrollView, mainView: UIView, singletonsStackView: UIView) {
        self.value = value
        queue = SkewBinomialHeapAnimation<BrodalPriorityQueueAnimation<Element>>(mainScrollView: mainScrollView, mainView: mainView, singletonsStackView: singletonsStackView)
    }
    
    init(value: Element, queue: SkewBinomialHeapAnimation<BrodalPriorityQueueAnimation<Element>>) {
        self.value = value
        self.queue = queue
    }
}

class BrodalPriorityQueueAnimation<Element: Comparable> : NSObject, Comparable, UIScrollViewDelegate {
    
    private var root: BPQNodeAnimation<Element>?
    
    var elementLabel: UILabel!
    var queueView: UIView!
    var mainScrollView: UIScrollView!
    var mainView: UIView!
    var singletonsStackView: UIView!
    var contentView: UIView!
    
    var isEmpty: Bool {
        return root == nil
    }
    
    //MARK: - Initialization
    
    private func createViews() {
        contentView = UIView(frame: superView.frame)
        mainScrollView = UIScrollView(frame: CGRect(x: 0, y: nodeSize, width: contentView.frame.size.width, height: contentView.frame.size.height - nodeSizeDifference - nodeOffset))
        queueView = UIView(frame: mainScrollView.frame)
        queueView.backgroundColor = .yellow
        mainView = UIView(frame: mainScrollView.frame)
        elementLabel = UILabel(frame: CGRect(x: 0, y: nodeOffset, width: nodeSize, height: nodeSize))
        elementLabel.text = description
        elementLabel.textAlignment = .center
        elementLabel.layer.borderWidth = lineWidth
        
        contentView.addSubview(queueView)
        contentView.addSubview(elementLabel)
        
        queueView.addSubview(mainScrollView)
        mainScrollView.addSubview(mainView)
        
        singletonsStackView = UIView(frame: CGRect(x: 0, y: queueView.frame.size.height, width: queueView.frame.size.width, height: 0))
        queueView.addSubview(singletonsStackView)
        
        
        singletonsStackView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        queueView.translatesAutoresizingMaskIntoConstraints = false
        elementLabel.translatesAutoresizingMaskIntoConstraints = false
        
        elementLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        elementLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        elementLabel.heightAnchor.constraint(equalToConstant: nodeSize).isActive = true
        elementLabel.widthAnchor.constraint(equalToConstant: nodeSize).isActive = true
        
        queueView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        queueView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        queueView.topAnchor.constraint(equalTo: elementLabel.bottomAnchor, constant: 0).isActive = true
        queueView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        
        
        mainScrollView.leadingAnchor.constraint(equalTo: queueView.leadingAnchor, constant: 0).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: queueView.trailingAnchor, constant: 0).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: queueView.topAnchor, constant: 0).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: queueView.bottomAnchor, constant: 0).isActive = true
        
        
        singletonsStackView.leadingAnchor.constraint(equalTo: queueView.leadingAnchor, constant: 0).isActive = true
        singletonsStackView.trailingAnchor.constraint(equalTo: queueView.trailingAnchor, constant: 0).isActive = true
        singletonsStackView.bottomAnchor.constraint(equalTo: queueView.bottomAnchor, constant: 0).isActive = true
        
        
        
        mainScrollView.delegate = self
        mainScrollView.minimumZoomScale = CGFloat.leastNormalMagnitude
        mainScrollView.maximumZoomScale = CGFloat.greatestFiniteMagnitude
        
    }
    
    private func copyRoot(other: BrodalPriorityQueueAnimation) {
        root = other.root
        elementLabel = other.elementLabel
        queueView = other.queueView
        mainScrollView = other.mainScrollView
        mainView = other.mainView
        singletonsStackView = other.singletonsStackView
        contentView = other.contentView
    }
    
    override init()  {
        super.init()
        createViews()
    }
    
    private init(value: Element) {
        super.init()
        createViews()
        root = BPQNodeAnimation(value: value, mainScrollView: mainScrollView, mainView: mainView, singletonsStackView: singletonsStackView)
        elementLabel.text = description
    }
    
    private init(value: Element,
                 queue: SkewBinomialHeapAnimation<BrodalPriorityQueueAnimation<Element>>) {
        super.init()
        createViews()
        root = BPQNodeAnimation(value: value, queue: queue)
        elementLabel.text = description
    }
    
    var first: Element? {
        if isEmpty {
            return nil
        }
        
        return root!.value
    }
    
    func merge(other: BrodalPriorityQueueAnimation) {
        if isEmpty {
            copyRoot(other: other)
            return
        }
        if other.isEmpty {
            return
        }
        
        if root!.value < other.root!.value {
            root!.queue.push(element: other)
            return
        }
        
        let selfCopy = BrodalPriorityQueueAnimation<Element>(value: root!.value, queue: root!.queue)
        root!.queue = other.root!.queue
        root!.queue.push(element: selfCopy)
        root!.value = other.root!.value
    }
    
    func insert(element: Element) {
        merge(other: BrodalPriorityQueueAnimation(value: element))
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
    
    static func <(lhs: BrodalPriorityQueueAnimation, rhs: BrodalPriorityQueueAnimation) -> Bool {
        if lhs.root == nil {
            return rhs.root != nil
        }
        if rhs.root == nil {
            return false
        }
        return lhs.root!.value < rhs.root!.value
    }
    
    static func <=(lhs: BrodalPriorityQueueAnimation, rhs: BrodalPriorityQueueAnimation) -> Bool {
        if lhs.root == nil {
            return true
        }
        if rhs.root == nil {
            return false
        }
        return lhs.root!.value <= rhs.root!.value
    }
    
    static func >=(lhs: BrodalPriorityQueueAnimation, rhs: BrodalPriorityQueueAnimation) -> Bool {
        if lhs.root == nil {
            return rhs.root == nil
        }
        if rhs.root == nil {
            return true
        }
        return lhs.root!.value >= rhs.root!.value
    }
    
    static func >(lhs: BrodalPriorityQueueAnimation, rhs: BrodalPriorityQueueAnimation) -> Bool {
        if lhs.root == nil {
            return false
        }
        if rhs.root == nil {
            return true
        }
        return lhs.root!.value > rhs.root!.value
    }
    
    //MARK: - Equatable
    
    static func ==(lhs: BrodalPriorityQueueAnimation, rhs: BrodalPriorityQueueAnimation) -> Bool {
        return lhs.root?.value == rhs.root?.value
    }
    
    // MARK:- UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mainView
    }
    
    // MARK:- Description
    
    override var description: String {
        return root == nil ? "" : "\(root!.value)"
    }
    
    override var debugDescription: String {
        return root == nil ? "" : "\(root!.value)"
    }
}
