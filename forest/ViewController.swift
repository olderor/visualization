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





class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var speedView: SpeedView!
    
    // MARK:- UIViewController
    
    var mainScrollView: UIScrollView!
    var mainView: UIView!
    var singletonsStackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsView = speedView
        superView = UIView(frame: self.view.frame)
        self.view.addSubview(superView)
        
        
        superView.translatesAutoresizingMaskIntoConstraints = false
        superView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        superView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        superView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        superView.bottomAnchor.constraint(equalTo: speedView.topAnchor, constant: 0).isActive = true
        
        let queue = BrodalPriorityQueueAnimation<Int>()
        superView.addSubview(queue.contentView)
        queue.contentView.translatesAutoresizingMaskIntoConstraints = false
        queue.contentView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
        queue.contentView.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
        queue.contentView.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
        queue.contentView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
        
        /*
        var elements = [Int]()
        
        print("inserting")
        for _ in 0..<100 {
            let element = Int(arc4random() % 100)
            print(element)
            queue.insert(element: element)
            elements.append(element)
        }
        print(elements)
        elements = elements.sorted()
        
        AnimationManager.addAnimation(animation: {
            sleep(10)
            print("deleting")
        }, completion: nil, type: .none)
        var index = 0
        print("deleting")
        while !queue.isEmpty {
            let element = queue.extractMin()!
            print(element)
            if elements[index] != element {
                print("error!!!\n\n\n\n\n")
            }
            index += 1
        }
         
         73, 41, 2, 87, 78, 38, 20, 50, 15, 75, 42, 90, 35, 65, 57, 23, 9, 44, 69, 2, 48, 77, 53, 44, 69, 67, 28, 79, 58, 88, 20, 11, 16, 52, 72, 62, 3, 35, 38, 7, 97, 43, 31, 58, 98, 93, 65, 96, 83, 29, 31, 51, 38, 97, 61, 56, 76, 59, 95, 20, 9, 21, 89, 60, 15, 25, 8, 85, 13, 78, 1, 74, 55, 42, 91, 55, 16, 77, 65, 92, 9, 10, 53, 85, 29, 20, 80, 85, 29, 97, 46, 91, 62, 99, 76, 73, 47, 86, 25, 12
         */
        queue.insert(element: 73)
        queue.insert(element: 41)
        queue.insert(element: 2)
        queue.insert(element: 87)
        queue.insert(element: 78)
        queue.insert(element: 38)
        queue.insert(element: 20)
        queue.insert(element: 50)
        queue.insert(element: 15)
        queue.insert(element: 75)
        queue.insert(element: 42)
        queue.insert(element: 90)
        queue.insert(element: 35)
        queue.insert(element: 65)
        queue.insert(element: 57)
        queue.insert(element: 23)
        queue.insert(element: 9)
        queue.insert(element: 44)
        queue.insert(element: 69)
        queue.insert(element: 2)
        queue.insert(element: 48)
        queue.insert(element: 77)
        queue.insert(element: 53)
        queue.insert(element: 44)
        queue.insert(element: 69)
        queue.insert(element: 67)
        queue.insert(element: 28)
        queue.insert(element: 79)
        queue.insert(element: 58)
        queue.insert(element: 88)
        queue.insert(element: 20)
        queue.insert(element: 11)
        queue.insert(element: 16)
        queue.insert(element: 52)
        queue.insert(element: 72)
        queue.insert(element: 62)
        queue.insert(element: 3)
        queue.insert(element: 35)
        queue.insert(element: 38)
        queue.insert(element: 7)
        queue.insert(element: 97)
        queue.insert(element: 43)
        queue.insert(element: 31)
        queue.insert(element: 58)
        queue.insert(element: 98)
        queue.insert(element: 93)
        queue.insert(element: 65)
        queue.insert(element: 96)
        queue.insert(element: 83)
        queue.insert(element: 29)
        queue.insert(element: 31)
        queue.insert(element: 51)
        queue.insert(element: 38)
        queue.insert(element: 97)
        queue.insert(element: 61)
        queue.insert(element: 56)
        queue.insert(element: 76)
        queue.insert(element: 59)
        queue.insert(element: 95)
        queue.insert(element: 20)
        queue.insert(element: 9)
        queue.insert(element: 21)
        queue.insert(element: 89)
        queue.insert(element: 60)
        queue.insert(element: 15)
        queue.insert(element: 25)
        queue.insert(element: 8)
        queue.insert(element: 85)
        queue.insert(element: 13)
        queue.insert(element: 78)
        queue.insert(element: 1)
        queue.insert(element: 74)
        queue.insert(element: 55)
        queue.insert(element: 42)
        queue.insert(element: 91)
        queue.insert(element: 55)
        queue.insert(element: 16)
        queue.insert(element: 77)
        queue.insert(element: 65)
        queue.insert(element: 92)
        queue.insert(element: 9)
        queue.insert(element: 10)
        queue.insert(element: 53)
        queue.insert(element: 85)
        queue.insert(element: 29)
        queue.insert(element: 20)
        queue.insert(element: 80)
        queue.insert(element: 85)
        queue.insert(element: 29)
        queue.insert(element: 97)
        queue.insert(element: 46)
        queue.insert(element: 91)
        queue.insert(element: 62)
        queue.insert(element: 99)
        queue.insert(element: 76)
        queue.insert(element: 73)
        queue.insert(element: 47)
        queue.insert(element: 86)
        queue.insert(element: 25)
        queue.insert(element: 12)
        
        AnimationManager.addAnimation(animation: {
            sleep(10)
            print("deleting")
            }, completion: nil, type: .none)
        
        var index = 0
        print("deleting")
        while !queue.isEmpty {
            let element = queue.extractMin()!
            print(element)
            index += 1
        }
        
        
        AnimationManager.play(completion: nil)
    }
    
    
    func runSkewBinomialHeap() {
        settingsView = speedView
        
        mainScrollView = UIScrollView(frame: self.view.frame)
        mainView = UIView(frame: self.view.frame)
        
        superView = UIView(frame: self.view.frame)
        
        self.view.addSubview(superView)
        superView.addSubview(mainScrollView)
        mainScrollView.addSubview(mainView)
        
        singletonsStackView = UIView(frame: CGRect(x: 0, y: speedView.frame.origin.y, width: self.view.frame.size.width, height: 0))
        superView.addSubview(singletonsStackView)
        
        
        singletonsStackView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        superView.translatesAutoresizingMaskIntoConstraints = false
        
        
        superView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        superView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        superView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        superView.bottomAnchor.constraint(equalTo: speedView.topAnchor, constant: 0).isActive = true
        
        
        mainScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: speedView.topAnchor, constant: 0).isActive = true
        
        
        singletonsStackView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
        singletonsStackView.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
        singletonsStackView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
        
        
        
        mainScrollView.delegate = self
        mainScrollView.minimumZoomScale = CGFloat.leastNormalMagnitude
        mainScrollView.maximumZoomScale = CGFloat.greatestFiniteMagnitude
        
        
        
        let skewHeap = SkewBinomialHeapAnimation<Int>(mainScrollView: mainScrollView, mainView: mainView, singletonsStackView: singletonsStackView)
        
        var result = ""
        
        for _ in 0...3 {
            for _ in 0..<Int(arc4random() % 20) + 5 {
                let element = Int(arc4random() % 100)
                skewHeap.push(element: element)
                print("push \(element)")
            }
            for _ in 0..<Int(arc4random() % 10) {
                let element = skewHeap.first
                skewHeap.pop()
                if element != nil {
                    print(element!)
                    result += " \(element!)"
                }
            }
            result += "\n"
        }
        while !skewHeap.isEmpty {
            let element = skewHeap.first
            skewHeap.pop()
            if element != nil {
                print(element!)
                result += " \(element!)"
            }
        }
        
        
        let alert = UIAlertController(title: "Done", message: result, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        
        AnimationManager.play(completion: ) { self.present(alert, animated: true, completion: nil) }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

/*
 
 
 4 16 57 56 82 90 12 7 90 54 61 70 54 97 
 - 4 7 12 16 54 54 56
 76 64 43 73 60 20 32 38 82 9 31 63 45 63 87
 - 9 20 31 32 38 43 45 57 60
 2 69 17 48 28 43 49 87 96 82 81 41 77 1 89 52 15 90 15 59 20 36 10 86 23
 - 1 2 10 15 15 17 20 23 28 36 41 43 48 49 52 59 61 63 63 64 69 70 73 76 77 81 82 82 82 86 87
 - 87 89 90 90 90 96 97
 
 
 
 
 - 4 7 12 16 54 54 56
 
 - 9 20 31 32 38 43 45 57 60
 
 - 1 2 10 15 15 17 20 23 28 36 41 43 48 49 52 59 61 63 63 64 69 70 73 76 77 81 82 82 82 86 87
 - 87 89 90 90 90 96 97
 */

