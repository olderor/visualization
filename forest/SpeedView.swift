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
    
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        AnimationManager.defaultDuration = Double(Int(sender.value)) / 100.0
        label.text = "Speed \(AnimationManager.defaultDuration)"
    }
    
    
    
}
