//
//  SpeedView.swift
//  forest
//
//  Created by olderor on 19.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit


class SpeedView : UIView {
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var queue: BrodalPriorityQueueAnimation<Int>!
    
    @IBAction func addElementTouchUpInside(sender: UIButton) {
        
        if queue == nil {
            queue = BrodalPriorityQueueAnimation<Int>()
            superView.addSubview(queue.contentView)
            queue.contentView.translatesAutoresizingMaskIntoConstraints = false
            queue.contentView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
            queue.contentView.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
            queue.contentView.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
            queue.contentView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
            
        }
        
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
        /*
         73, 41, 2, 87, 78, 38, 20, 50, 15, 75, 42, 90, 35, 65, 57, 23, 9, 44, 69, 2, 48, 77, 53, 44, 69, 67, 28, 79, 58, 88, 20, 11, 16, 52, 72, 62, 3, 35, 38, 7, 97, 43, 31, 58, 98, 93, 65, 96, 83, 29, 31, 51, 38, 97, 61, 56, 76, 59, 95, 20, 9, 21, 89, 60, 15, 25, 8, 85, 13, 78, 1, 74, 55, 42, 91, 55, 16, 77, 65, 92, 9, 10, 53, 85, 29, 20, 80, 85, 29, 97, 46, 91, 62, 99, 76, 73, 47, 86, 25, 12
         */
        
        /*
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
         queue.insert(element: 12)*/
        
        AnimationManager.play(completion: nil)
    }
    
    @IBAction func removeElementTouchUpInside(sender: UIButton) {
        
        var index = 0
        print("deleting")
        while !queue.isEmpty {
            let element = queue.extractMin()!
            print(element)
            index += 1
        }
        
        AnimationManager.play(completion: nil)
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        AnimationManager.defaultDuration = Double(Int(sender.value)) / 100.0
        label.text = "Speed \(AnimationManager.defaultDuration) seconds per operation"
    }
    
    
    
}
