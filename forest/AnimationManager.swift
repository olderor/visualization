//
//  AnimationManager.swift
//  forest
//
//  Created by olderor on 17.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit

enum AnimationType {
    case animation, transition, none
}

class Animation {
    var animation: () -> Swift.Void
    var completion: ((Bool) -> Swift.Void)?
    var duration: TimeInterval
    var type: AnimationType
    
    init(animation: @escaping () -> Swift.Void,
         completion: ((Bool) -> Swift.Void)?,
         duration: TimeInterval,
         type: AnimationType) {
        self.animation = animation
        self.completion = completion
        self.duration = duration
        self.type = type
    }
    
    func play(onComplete: (() -> Swift.Void)?) {
        switch type {
        case .transition:
            UIView.transition(with: mainView,
                              duration: AnimationManager.defaultDuration,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: animation,
                              completion: { (finished: Bool) -> Void in
                                if self.completion != nil {
                                    self.completion!(finished)
                                }
                                if onComplete != nil {
                                    onComplete!()
                                }
            })
            break
        case .none:
            animation()
            if completion != nil {
                completion!(true)
            }
            if onComplete != nil {
                onComplete!()
            }
            break
        default:
            UIView.animate(withDuration: AnimationManager.defaultDuration,
                           animations: animation,
                           completion: { (finished: Bool) -> Void in
                            if self.completion != nil {
                                self.completion!(finished)
                            }
                            if onComplete != nil {
                                onComplete!()
                            }
            })
            break
        }
    }
}

class AnimationManager {
    
    static private var animations = Deque<Animation>()
    
    static var defaultDuration: TimeInterval = 0.2
    
    static private(set) var isRunning = false
    
    static func addAnimation(animation: Animation) {
        animations.append(animation)
    }
    
    static func addAnimation(animation: @escaping () -> Swift.Void, completion: ((Bool) -> Swift.Void)?, type: AnimationType) {
        addAnimation(animation: animation, completion: completion, duration: defaultDuration, type: type)
    }
    
    static func addAnimation(animation: @escaping () -> Swift.Void, completion: ((Bool) -> Swift.Void)?, duration: TimeInterval, type: AnimationType) {
        addAnimation(animation: Animation(animation: animation, completion: completion, duration: duration, type: type))
    }
    
    
    static func playAnimation() {
        isRunning = true
        if animations.isEmpty {
            isRunning = false
            return
        }
        let animation = animations.removeFirst()
        animation.play(onComplete: playAnimation)
    }
}
