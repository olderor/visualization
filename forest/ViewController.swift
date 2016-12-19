//
//  ViewController.swift
//  forest
//
//  Created by olderor on 20.11.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scrollView = UIScrollView(frame: self.view.frame)
        self.view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        scrollView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 0).isActive = true
        
        
        mainView = scrollView
        
        
        
        print("done")
        
        let skewHeap = SkewBinomialHeapAnimation<Int>()
        for _ in 0..<200 {
            let element = Int(arc4random() % 100)
            skewHeap.push(element: element)
            print("push \(element)")
        }
        print(skewHeap.first)
        AnimationManager.playAnimation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

