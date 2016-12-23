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
    
    init(other: BPQNodeAnimation) {
        value = other.value
        queue = other.queue
        mainScrollView = other.mainScrollView
        mainView = other.mainView
        singletonsStackView = other.singletonsStackView
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
    
    var delegate: SkewBinomialHeapDelegate?
    
    //MARK: - Initialization
    
    private func createViews() {
        contentView = UIView(frame: superView.frame)
        mainScrollView = UIScrollView(frame: CGRect(x: 0, y: nodeSize, width: contentView.frame.size.width, height: contentView.frame.size.height - nodeSizeDifference - nodeOffset))
        queueView = UIView(frame: mainScrollView.frame)
        queueView.layer.borderWidth = lineWidth
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
        queueView.topAnchor.constraint(equalTo: elementLabel.bottomAnchor, constant: 20).isActive = true
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
        copyViews(other: other)
    }
    
    private func copyViews(other: BrodalPriorityQueueAnimation) {
        elementLabel = other.elementLabel
        queueView = other.queueView
        mainScrollView = other.mainScrollView
        mainView = other.mainView
        singletonsStackView = other.singletonsStackView
        contentView = other.contentView
        mainScrollView.delegate = self
    }
    
    override init()  {
        super.init()
        createViews()
        root?.queue.delegate = delegate
    }
    
    private init(value: Element) {
        super.init()
        createViews()
        root = BPQNodeAnimation(value: value, mainScrollView: mainScrollView, mainView: mainView, singletonsStackView: singletonsStackView)
        elementLabel.text = description
        root?.queue.delegate = delegate
    }
    
    private init(value: Element,
                 queue: SkewBinomialHeapAnimation<BrodalPriorityQueueAnimation<Element>>) {
        super.init()
        createViews()
        root = BPQNodeAnimation(value: value, queue: queue)
        elementLabel.text = description
    }
    
    private init(other: BrodalPriorityQueueAnimation) {
        super.init()
        copyViews(other: other)
        root = BPQNodeAnimation(other: other.root!)
        elementLabel.text = description
        delegate = root!.queue.delegate
    }
    
    //MARK:- Queue functions
    
    var first: Element? {
        if isEmpty {
            return nil
        }
        AnimationManager.addAnimation(animation: {
            print(AnimationManager.defaultDuration)
            self.elementLabel.backgroundColor = .yellow
        }, completion: nil, type: .transition, description: "minimum is found")
        AnimationManager.addAnimation(animation: {
            print(AnimationManager.defaultDuration)
            self.elementLabel.backgroundColor = .white
        }, completion: nil, type: .transition, description: nil)
        AnimationManager.addAnimation(animation: {
            print(AnimationManager.defaultDuration)
            self.elementLabel.backgroundColor = .yellow
            }, completion: nil, type: .transition, description: nil)
        AnimationManager.addAnimation(animation: {
            print(AnimationManager.defaultDuration)
            self.elementLabel.backgroundColor = .white
            }, completion: nil, type: .transition, description: nil)
        AnimationManager.addAnimation(animation: {
            print(AnimationManager.defaultDuration)
            self.elementLabel.backgroundColor = .yellow
            }, completion: nil, type: .transition, description: nil)
        AnimationManager.addAnimation(animation: {
            print(AnimationManager.defaultDuration)
            self.elementLabel.backgroundColor = .white
            }, completion: nil, type: .transition, description: nil)
        return root!.value
    }
    
    func merge(other: BrodalPriorityQueueAnimation) {
        other.delegate = delegate
        other.root?.queue.delegate = delegate
        if isEmpty {
            let previousContentView = contentView!
            copyRoot(other: other)
            let currentContentView = contentView!
            AnimationManager.addAnimation(animation: {
                if let parent = previousContentView.superview {
                    previousContentView.removeFromSuperview()
                    self.addSubview(view: currentContentView, parent: parent)
                }
                }, completion: nil, type: .transition, description: "making new root")
            return
        }
        if other.isEmpty {
            return
        }
        
        if root!.value < other.root!.value {
            root!.queue.push(element: other)
            return
        }
        
        let selfCopy = BrodalPriorityQueueAnimation<Element>(other: self)
        copyRoot(other: other)
        
        var label: UILabel!
        
        AnimationManager.addAnimation(animation: {
            label = UILabel(frame: selfCopy.elementLabel.frame)
            label.layer.borderWidth = lineWidth
            label.textAlignment = .center
            label.text = selfCopy.elementLabel.text
            label.alpha = 0.0
            if selfCopy.contentView.superview != nil {
                superView.addSubview(label)
            }
        }, completion: nil, type: .none, description: nil)
        AnimationManager.addAnimation(animation: {
            label.alpha = 1.0
        }, completion: nil, type: .animation, description: "merging")
        AnimationManager.addAnimation(animation: {
            label.backgroundColor = .yellow
        }, completion: nil, type: .animation, description: "merging")
        let currentContentView = contentView!
        var parent: UIView!
        AnimationManager.addAnimation(animation: {
            parent = selfCopy.contentView.superview
            if parent != nil {
                selfCopy.contentView.alpha = 0.0
            }
        }, completion: nil, type: .animation, description: nil)
        AnimationManager.addAnimation(animation: {
            parent = selfCopy.contentView.superview
            if parent != nil {
                selfCopy.contentView.removeFromSuperview()
                selfCopy.contentView.alpha = 1.0
            }
        }, completion: nil, type: .none, description: nil)
        AnimationManager.addAnimation(animation: {
            label.frame.origin.x = superView.frame.size.width - label.frame.size.width - 10
        }, completion: nil, type: .animation, description: "add root to the queue")
        AnimationManager.addAnimation(animation: {
            label.backgroundColor = .green
        }, completion: nil, type: .animation, description: "add root to the queue")
        AnimationManager.addAnimation(animation: {
            if parent != nil {
                currentContentView.alpha = 0.0
                self.addSubview(view: currentContentView, parent: parent)
            }
        }, completion: nil, type: .none, description: "add root to the queue")
        AnimationManager.addAnimation(animation: {
            if parent != nil {
                currentContentView.alpha = 1.0
            }
        }, completion: nil, type: .animation, description: "add root to the queue")
        root!.queue.push(element: selfCopy)
        AnimationManager.addAnimation(animation: {
            label.alpha = 0.0
        }, completion: nil, type: .animation, description: "add root to the queue")
        AnimationManager.addAnimation(animation: {
            label.removeFromSuperview()
        }, completion: nil, type: .none, description: nil)
    }
    
    private func addSubview(view: UIView, parent: UIView) {
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: parent.topAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: 0).isActive = true
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
            elementLabel.text = description
            return minElement
        }
        let minBpq = root!.queue.first!
        let value = minBpq.root!.value
        AnimationManager.addAnimation(animation: {
            self.elementLabel.text = "\(value)"
        }, completion: nil, type: .animation, description: "changing root")
        root!.queue.pop()
        root!.queue.merge(other: minBpq.root!.queue)
        root!.value = value
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
        if scrollView.subviews.count == 0 {
            return nil
        }
        return scrollView.subviews[0]
    }
    
    // MARK:- Description
    
    override var description: String {
        return root == nil ? "" : String(describing: root!.value)
    }
    
    override var debugDescription: String {
        return root == nil ? "" : String(describing: root!.value)
    }
}
