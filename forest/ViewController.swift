//
//  ViewController.swift
//  forest
//
//  Created by olderor on 20.11.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit


var superView: UIView!
var settingsView: UIView!


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





class ViewController: UIViewController, UIScrollViewDelegate, AnimationManagerDelegate, ControlDelegate, SkewBinomialHeapDelegate {
    
    
    // MARK:- IBOutlets and IBActions
    
    @IBOutlet weak var animationByStepSwitch: UISwitch!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var speedView: SpeedView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var titleNavigationItem: UINavigationItem!
    
    @IBAction func backBarButtonItemOnTouchUpInside(_ sender: UIBarButtonItem) {
        AnimationManager.clear()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onAnimationByStepSwitchValueChanged(_ sender: UISwitch) {
        nextButton.isEnabled = sender.isOn
    }
    
    @IBAction func onNextButtonTouchUpInside(_ sender: UIButton) {
        AnimationManager.playNext()
    }
    // MARK:- UIViewController
    
    var mainScrollView: UIScrollView!
    var mainView: UIView!
    var singletonsStackView: UIView!
    
    var hasControlls = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        settingsView = speedView
        superView = UIView(frame: self.view.frame)
        self.view.addSubview(superView)
        
        
        superView.translatesAutoresizingMaskIntoConstraints = false
        superView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        superView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        superView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0).isActive = true
        
        
        if !hasControlls {
            speedView.removeFromSuperview()
            superView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
            superView.addSubview(mainView)
            
            mainView.translatesAutoresizingMaskIntoConstraints = false
            mainView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
            mainView.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
            mainView.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
            mainView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
            return
        }
        
        superView.bottomAnchor.constraint(equalTo: speedView.topAnchor, constant: 0).isActive = true
        AnimationManager.delegate = self
        speedView.delegate = self
        
        switch TaskManager.sturctureType {
        case .queue:
            checkIfQueueExist()
            break
        case .heap:
            checkIfHeapExist()
            break
        }
    }
    
    //MARK:- SkewBinomialHeapDelegate
    
    func onElementTouchUpInside(element: Any) {
        
        if AnimationManager.isRunning {
            return
        }
        
        let queue = element as? BrodalPriorityQueueAnimation<MyString>
        if queue == nil {
            return
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "vc") as! ViewController
        vc.hasControlls = false
        vc.mainView = queue!.contentView
        if let topController = UIApplication.topViewController() {
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK:- ControlDelegate
    
    func checkIfQueueExist() {
        if speedView.queue == nil {
            speedView.queue = BrodalPriorityQueueAnimation<MyString>()
            speedView.queue.delegate = self
            superView.addSubview(speedView.queue.contentView)
            
            speedView.queue.contentView.translatesAutoresizingMaskIntoConstraints = false
            speedView.queue.contentView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
            speedView.queue.contentView.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
            speedView.queue.contentView.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
            speedView.queue.contentView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
            
        }
    }
    
    func checkIfHeapExist() {
        if speedView.heap == nil {
            
            mainScrollView = UIScrollView(frame: self.view.frame)
            mainView = UIView(frame: self.view.frame)
            
            superView.addSubview(mainScrollView)
            mainScrollView.addSubview(mainView)
            
            singletonsStackView = UIView(frame: CGRect(x: 0, y: speedView.frame.origin.y, width: self.view.frame.size.width, height: 0))
            superView.addSubview(singletonsStackView)
            
            
            singletonsStackView.translatesAutoresizingMaskIntoConstraints = false
            mainScrollView.translatesAutoresizingMaskIntoConstraints = false
            superView.translatesAutoresizingMaskIntoConstraints = false
            
            
            mainScrollView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
            mainScrollView.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
            mainScrollView.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
            mainScrollView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
            
            
            singletonsStackView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
            singletonsStackView.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
            singletonsStackView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
            
            
            
            mainScrollView.delegate = self
            mainScrollView.minimumZoomScale = CGFloat.leastNormalMagnitude
            mainScrollView.maximumZoomScale = CGFloat.greatestFiniteMagnitude
            
            
            
            speedView.heap = SkewBinomialHeapAnimation<MyString>(mainScrollView: mainScrollView, mainView: mainView, singletonsStackView: singletonsStackView)
        }
    }
    
    func addElementToQueue() {
        
        switch TaskManager.taskType {
        case .equal:
            for _ in 0..<100 {
                speedView.queue.insert(element: MyString(value: "0"))
            }
            break
        case .increasing:
            for i in 0..<100 {
                speedView.queue.insert(element: MyString(value: "\(i)"))
            }
            break
        case .decreasing:
            for i in 0..<100 {
                speedView.queue.insert(element: MyString(value: "\(100 - i)"))
            }
            break
        case .random:
            for _ in 0..<100 {
                let element = Int(arc4random() % 100)
                print(element)
                speedView.queue.insert(element: MyString(value: "\(element)"))
            }
            break
        case .custom:
            let alertController = UIAlertController(title: "Input", message: "Enter element", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Done", style: .default, handler: { (_) in
                if let field = alertController.textFields?[0] {
                    self.speedView.queue.insert(element: MyString(value: field.text!))
                    AnimationManager.play(isByStep: self.animationByStepSwitch.isOn)
                } else {
                    self.didFinishAnimation()
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in self.didFinishAnimation() })
            alertController.addTextField(configurationHandler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            break
        }
        switch TaskManager.taskType {
        case .equal, .increasing, .decreasing, .random:
            AnimationManager.play(isByStep: animationByStepSwitch.isOn)
            break
        default:
            break
        }
    }
    
    func addElementToHeap() {
        
        switch TaskManager.taskType {
        case .equal:
            for _ in 0..<100 {
                speedView.heap.push(element: MyString(value: "0"))
            }
            break
        case .increasing:
            for i in 0..<100 {
                speedView.heap.push(element: MyString(value: "\(i)"))
            }
            break
        case .decreasing:
            for i in 0..<100 {
                speedView.heap.push(element: MyString(value: "\(100 - i)"))
            }
            break
        case .random:
            for _ in 0..<100 {
                let element = Int(arc4random() % 100)
                print(element)
                speedView.heap.push(element: MyString(value: "\(element)"))
            }
            break
        case .custom:
            let alertController = UIAlertController(title: "Input", message: "Enter element", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Done", style: .default, handler: { (_) in
                if let field = alertController.textFields?[0] {
                    self.speedView.heap.push(element: MyString(value: field.text!))
                    AnimationManager.play(isByStep: self.animationByStepSwitch.isOn)
                } else {
                    self.didFinishAnimation()
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in self.didFinishAnimation() })
            alertController.addTextField(configurationHandler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            break
        }
        
        switch TaskManager.taskType {
        case .equal, .increasing, .decreasing, .random:
            AnimationManager.play(isByStep: animationByStepSwitch.isOn)
            break
        default:
            break
        }
    }
    
    func onAddElement() {
        switch TaskManager.sturctureType {
        case .queue:
            addElementToQueue()
            break
        case .heap:
            addElementToHeap()
            break
        }
    }
    
    func removeFromHeap() {
        if speedView.heap == nil {
            let message = "Queue is empty. Nothing to extract."
            let alertController = UIAlertController(title: "Done", message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(confirmAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        switch TaskManager.taskType {
        case .equal, .increasing, .decreasing, .random:
            while !speedView.heap.isEmpty {
                let element = speedView.heap.pop()!
                print(element)
            }
            AnimationManager.play(isByStep: animationByStepSwitch.isOn)
            break
        default:
            let element = speedView.heap.pop()
            print(element)
            let message = element == nil ? "Queue is empty. Nothing to extract." : "\(element!)"
            let alertController = UIAlertController(title: "Done", message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in AnimationManager.play(isByStep: self.animationByStepSwitch.isOn) })
            alertController.addAction(confirmAction)
            self.present(alertController, animated: true, completion: nil)
            break
        }
    }
    
    func removeFromQueue() {
        if speedView.queue == nil {
            let message = "Queue is empty. Nothing to extract."
            let alertController = UIAlertController(title: "Done", message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in AnimationManager.play(isByStep: self.animationByStepSwitch.isOn) })
            alertController.addAction(confirmAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        switch TaskManager.taskType {
        case .equal, .increasing, .decreasing, .random:
            while !speedView.queue.isEmpty {
                let element = speedView.queue.extractMin()!
                print(element)
            }
            AnimationManager.play(isByStep: animationByStepSwitch.isOn)
            break
        default:
            let element = speedView.queue.extractMin()
            print(element)
            let message = element == nil ? "Queue is empty. Nothing to extract." : "\(element!)"
            let alertController = UIAlertController(title: "Done", message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in AnimationManager.play(isByStep: self.animationByStepSwitch.isOn) })
            alertController.addAction(confirmAction)
            self.present(alertController, animated: true, completion: nil)
            break
        }
    }
    
    func retrieveFromQueue() {
        let element = speedView.queue.first
        print(element)
        let message = element == nil ? "Queue is empty." : "\(element!)"
        let alertController = UIAlertController(title: "Done", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in AnimationManager.play(isByStep: self.animationByStepSwitch.isOn) })
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func retrieveFromHeap() {
        let element = speedView.heap.first
        print(element)
        let message = element == nil ? "Queue is empty." : "\(element!)"
        let alertController = UIAlertController(title: "Done", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in AnimationManager.play(isByStep: self.animationByStepSwitch.isOn) })
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func onRetrieveElement() {
        
        switch TaskManager.sturctureType {
        case .queue:
            retrieveFromQueue()
            break
        case .heap:
            retrieveFromHeap()
            break
        }
    }
    
    func onRemoveElement() {
        
        switch TaskManager.sturctureType {
        case .queue:
            removeFromQueue()
            break
        case .heap:
            removeFromHeap()
            break
        }
    }
    
        
    
    // MARK:- AnimationManagerDelegate
    
    func willPlayAnimation(animationDescription: String) {
        if animationDescription == "" {
            return
        }
        titleNavigationItem.title = animationDescription
    }
    
    func didPlayAnimation(animationDescription: String) {
        // titleNavigationItem.title = ""
    }
    
    func didFinishAnimation() {
        titleNavigationItem.title = "Done"
        speedView.addButton.isEnabled = true
        speedView.retrieveButton.isEnabled = true
        speedView.removeButton.isEnabled = true
    }
    
    // MARK:- UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView.subviews.count == 0 {
            return nil
        }
        return scrollView.subviews[0]
    }

}
