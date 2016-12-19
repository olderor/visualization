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
        
        mainView = self.view
        
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

