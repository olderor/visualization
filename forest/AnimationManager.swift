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

protocol AnimationManagerDelegate: class {
    func willPlayAnimation(animationDescription: String)
    func didPlayAnimation(animationDescription: String)
    func didFinishAnimation()
}


class Animation {
    var animation: () -> Swift.Void
    var completion: ((Bool) -> Swift.Void)?
    var duration: TimeInterval
    var type: AnimationType
    
    var description: String
    
    init(animation: @escaping () -> Swift.Void,
         completion: ((Bool) -> Swift.Void)?,
         duration: TimeInterval,
         type: AnimationType,
         description: String?) {
        self.animation = animation
        self.completion = completion
        self.duration = duration
        self.type = type
        self.description = description == nil ? "" : description!
    }
    
    func play(onComplete: (() -> Swift.Void)?) {
        switch type {
        case .transition:
            UIView.transition(with: superView,
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
    
    static var defaultDuration: TimeInterval = 0.5
    
    static private(set) var isRunning = false
    
    static func addAnimation(animation: Animation) {
        animations.append(animation)
    }
    
    static func addAnimation(animation: @escaping () -> Swift.Void, completion: ((Bool) -> Swift.Void)?, type: AnimationType, description: String?) {
        addAnimation(animation: animation, completion: completion, duration: defaultDuration, type: type, description: description)
    }
    
    static func addAnimation(animation: @escaping () -> Swift.Void, completion: ((Bool) -> Swift.Void)?, duration: TimeInterval, type: AnimationType, description: String?) {
        addAnimation(animation: Animation(animation: animation, completion: completion, duration: duration, type: type, description: description))
    }
    
    static weak var delegate: AnimationManagerDelegate?
    
    
    static func playAll() {
        isRunning = true
        if animations.isEmpty {
            isRunning = false
            delegate?.didFinishAnimation()
            return
        }
        let animation = animations.removeFirst()
        delegate?.willPlayAnimation(animationDescription: animation.description)
        animation.play(onComplete: ) {
            delegate?.didPlayAnimation(animationDescription: animation.description)
            playAll()
        }
    }
    
    static func playNext() {
        if animations.isEmpty {
            return
        }
        isRunning = true
        let animation = animations.removeFirst()
        delegate?.willPlayAnimation(animationDescription: animation.description)
        animation.play(onComplete: ) {
            delegate?.didPlayAnimation(animationDescription: animation.description)
        }
        if animations.isEmpty {
            isRunning = false
            delegate?.didFinishAnimation()
        }
    }
    
    static func play(isByStep: Bool) {
        if isByStep {
            playNext()
        } else {
            playAll()
        }
    }
    
    static func clear() {
        animations.removeAll()
        defaultDuration = 0.5
    }
}

