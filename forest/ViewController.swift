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
        
        mainScrollView = UIScrollView(frame: self.view.frame)
        mainView = UIView(frame: self.view.frame)
        
        let view = UIView(frame: self.view.frame)
        
        self.view.addSubview(view)
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(mainView)
        
        singletonsStackView = UIView(frame: CGRect(x: 0, y: speedView.frame.origin.y, width: self.view.frame.size.width, height: 0))
        view.addSubview(singletonsStackView)
        
        
        singletonsStackView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        view.bottomAnchor.constraint(equalTo: speedView.topAnchor, constant: 0).isActive = true
        
        
        mainScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: speedView.topAnchor, constant: 0).isActive = true
        
        
        singletonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        singletonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        singletonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        
        
        mainScrollView.delegate = self
        mainScrollView.minimumZoomScale = CGFloat.leastNormalMagnitude
        mainScrollView.maximumZoomScale = CGFloat.greatestFiniteMagnitude

        
        
        let skewHeap = SkewBinomialHeapAnimation<Int>()
        
        for _ in 0..<22 {
            let element = Int(arc4random() % 100)
            skewHeap.push(element: element)
            print("push \(element)")
        }
        for _ in 0..<Int(arc4random() % 10) {
            print(skewHeap.pop())
        }
        
        while !skewHeap.isEmpty {
            print(skewHeap.pop())
        }
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

