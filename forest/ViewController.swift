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
        for i in 0..<200 {
            skewHeap.push(element: i)
            print("push \(i)")
        }
        AnimationManager.playAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

