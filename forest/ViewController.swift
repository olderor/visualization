//
//  ViewController.swift
//  forest
//
//  Created by olderor on 20.11.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var speedView: SpeedView!
    
    // MARK:- UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scrollView = UIScrollView(frame: self.view.frame)
        let subView = UIView(frame: self.view.frame)
        self.view.addSubview(scrollView)
        scrollView.addSubview(subView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: speedView.topAnchor, constant: 0).isActive = true
        
        
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = CGFloat.leastNormalMagnitude
        scrollView.maximumZoomScale = CGFloat.greatestFiniteMagnitude

        mainScrollView = scrollView
        mainView = subView
        
        
        
        let skewHeap = SkewBinomialHeapAnimation<Int>()
        for _ in 0..<4 {
            let element = Int(arc4random() % 100)
            skewHeap.push(element: element)
            print("push \(element)")
        }
        print(skewHeap.pop())
        AnimationManager.playAnimation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK:- UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mainView
    }
    


}

