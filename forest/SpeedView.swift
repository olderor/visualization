//
//  SpeedView.swift
//  forest
//
//  Created by olderor on 19.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit


protocol ControlDelegate: class {
    func onAddElement()
    func onRemoveElement()
}

class SpeedView : UIView {
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var queue: BrodalPriorityQueueAnimation<MyString>!
    var heap: SkewBinomialHeapAnimation<MyString>!
    
    weak var delegate: ControlDelegate?
    
    @IBAction func addElementTouchUpInside(sender: UIButton) {
        
        removeButton.isEnabled = false
        addButton.isEnabled = false
        
        delegate?.onAddElement()
        
    }
    
    @IBAction func removeElementTouchUpInside(sender: UIButton) {
        
        removeButton.isEnabled = false
        addButton.isEnabled = false
        
        delegate?.onRemoveElement()
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        AnimationManager.defaultDuration = Double(Int(sender.value)) / 100.0
        label.text = "Speed \(AnimationManager.defaultDuration) seconds per operation"
    }
    
    
    
}
