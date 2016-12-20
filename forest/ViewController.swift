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
        
        var result = ""
        
        for _ in 0...3 {
            for _ in 0..<Int(arc4random() % 20) + 5 {
                let element = Int(arc4random() % 100)
                skewHeap.push(element: element)
                print("push \(element)")
            }
            for _ in 0..<Int(arc4random() % 10) {
                let element = skewHeap.first
                skewHeap.pop()
                if element != nil {
                    print(element!)
                    result += " \(element!)"
                }
            }
            result += "\n"
        }
        while !skewHeap.isEmpty {
            let element = skewHeap.first
            skewHeap.pop()
            if element != nil {
                print(element!)
                result += " \(element!)"
            }
        }
        
        
        let alert = UIAlertController(title: "Done", message: result, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        
        AnimationManager.play(completion: ) { self.present(alert, animated: true, completion: nil) }
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

/*
 
 
 4 16 57 56 82 90 12 7 90 54 61 70 54 97 
 - 4 7 12 16 54 54 56
 76 64 43 73 60 20 32 38 82 9 31 63 45 63 87
 - 9 20 31 32 38 43 45 57 60
 2 69 17 48 28 43 49 87 96 82 81 41 77 1 89 52 15 90 15 59 20 36 10 86 23
 - 1 2 10 15 15 17 20 23 28 36 41 43 48 49 52 59 61 63 63 64 69 70 73 76 77 81 82 82 82 86 87
 - 87 89 90 90 90 96 97
 
 
 
     
 - 4 7 12 16 54 54 56
 
 - 9 20 31 32 38 43 45 57 60
 
 - 1 2 10 15 15 17 20 23 28 36 41 43 48 49 52 59 61 63 63 64 69 70 73 76 77 81 82 82 82 86 87
 - 87 89 90 90 90 96 97
 */

