//
//  AnimationManager.swift
//  forest
//
//  Created by olderor on 17.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit

class Animation {
    var animation: () -> Swift.Void
    var completion: ((Bool) -> Swift.Void)?
    var duration: TimeInterval
    
    init(animation: @escaping () -> Swift.Void, completion: ((Bool) -> Swift.Void)?, duration: TimeInterval) {
        self.animation = animation
        self.completion = completion
        self.duration = duration
    }
}

class AnimationManager {
    
    static private var animations = Deque<Animation>()
    
    static var defaultDelay: TimeInterval = 0.01
    
    static func addAnimation(animation: Animation) {
        animations.append(animation)
    }
    
    static func addAnimation(animation: @escaping () -> Swift.Void, completion: ((Bool) -> Swift.Void)?) {
        addAnimation(animation: animation, completion: completion, duration: defaultDelay)
    }
    
    static func addAnimation(animation: @escaping () -> Swift.Void, completion: ((Bool) -> Swift.Void)?, duration: TimeInterval) {
        addAnimation(animation: Animation(animation: animation, completion: completion, duration: duration))
    }
    
    
    static func playAnimation() {
        if animations.isEmpty {
            return
        }
        let animation = animations.removeFirst()
        UIView.animate(withDuration: animation.duration,
                       animations: animation.animation,
                       completion: { (finished: Bool) -> Void in
                        if animation.completion != nil {
                            animation.completion!(finished)
                        }
                        playAnimation()
        })
    }
}
