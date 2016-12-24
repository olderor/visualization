//
//  TreeViewController.swift
//  forest
//
//  Created by olderor on 23.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit


class TreeViewController : UIViewController {
    
    var decorasions = [UILabel]()
    var starLabel: UILabel!
    
    
    var mainView: UIView!
    
    var counter = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView = UIView(frame: self.view.frame)
        
        buildTree()
        
        starLabel = UILabel(frame: CGRect(x: self.view.frame.midX - 75 / 2 + 2, y: 120 - 80, width: 75, height: 75))
        starLabel.text = "⭐"
        starLabel.tag = 0
        starLabel.font = starLabel.font.withSize(70)
        starLabel.layer.zPosition = 10
        starLabel.textAlignment = .center
        starLabel.alpha = 0.0
        AnimationManager.addAnimation(animation: {
            AnimationManager.defaultDuration = 0.5
        }, completion: nil, duration: 1, type: .none, description: nil)
        AnimationManager.addAnimation(animation: {
            self.starLabel.alpha = 1.0
        }, completion: nil, duration: 1, type: .animation, description: nil)
        self.view.addSubview(starLabel)
        buildDecorations()
        
        
        AnimationManager.addAnimation(animation: {
            AnimationManager.defaultDuration = 1
        }, completion: nil, duration: 1, type: .none, description: nil)
        
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 720, width: self.view.frame.width, height: 152))
        nameLabel.font = UIFont(name: "MerryChristmasFlake", size: 150)
        nameLabel.textColor = UIColor(red: 0, green: 200.0 / 255.0, blue: 1.0, alpha: 1.0)
        nameLabel.textAlignment = .center
        nameLabel.text = "Forest"
        nameLabel.alpha = 0.0
        AnimationManager.addAnimation(animation: {
            nameLabel.alpha = 1.0
        }, completion: nil, duration: 1, type: .animation, description: nil)
        self.view.addSubview(nameLabel)
        
        let descriptionLabel = UILabel(frame: CGRect(x: 0, y: 900, width: self.view.frame.width, height: 80))
        descriptionLabel.font = UIFont(name: "Georgia", size: 30)
        descriptionLabel.textColor = UIColor(red: 0, green: 200.0 / 255.0, blue: 1.0, alpha: 1.0)
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "learning to rest"
        descriptionLabel.alpha = 0.0
        AnimationManager.addAnimation(animation: {
            descriptionLabel.alpha = 1.0
        }, completion: nil, duration: 1, type: .animation, description: nil)
        self.view.addSubview(descriptionLabel)
        AnimationManager.addAnimation(animation: {
            AnimationManager.defaultDuration = 0.5
        }, completion: nil, duration: 1, type: .none, description: nil)
        AnimationManager.playAll()
        
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
    }
    
    func timerTick() {
        
        
        if counter == 15 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "root")
            self.dismiss(animated: false, completion: nil)
            self.present(vc!, animated: true, completion: nil)
        }
        
        counter += 1
        
        if starLabel.tag == 1 {
            starLabel.text = "⭐"
            starLabel.tag = 0
        } else {
            starLabel.text = "🌟"
            starLabel.tag = 1
        }
        for label in decorasions {
            label.text = getRandomDecorationText()
            label.backgroundColor = getRandomDecorationColor()
        }
    }
    
    private func getBezierPoint(start: CGPoint, end: CGPoint, mid: CGPoint, percentage: CGFloat) -> CGPoint {
        func bezier(start: CGFloat, end: CGFloat, mid: CGFloat, percentage: CGFloat) -> CGFloat {
            return (1 - percentage) * (1 - percentage) * start + 2 * (1 - percentage) * percentage * mid + percentage * percentage * end
        }
        
        let x = bezier(start: start.x, end: end.x, mid: mid.x, percentage: percentage)
        let y = bezier(start: start.y, end: end.y, mid: mid.y, percentage: percentage)
        
        return CGPoint(x: x, y: y)
    }
    
    private func getRandomDecorationColor() -> UIColor {
        return UIColor(hue: CGFloat(drand48()), saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
    
    private func getRandomDecorationText() -> String {
        let symbs = ["🎄", "🌲", "⭐", "🌟", "🍊", "🍭", "🍦", "🍫", "🍰", "🍩", "🍾", "🎈", "🎉", "🍑", "🍏", "🐔", "⛄", "☃", "❄", "🕯", "💎", "🎁"]
        return symbs[Int(arc4random() % UInt32(symbs.count))]
    }
    
    private func buildDecorations() {
        let midX = self.view.frame.midX - nodeSize / 2
        var curY: CGFloat = 120 + nodeSize / 2
        var difX = CGFloat(0)
        AnimationManager.addAnimation(animation: {
            AnimationManager.defaultDuration = 0.01
        }, completion: nil, duration: 1, type: .none, description: nil)
        for i in 0..<6 {
            let nextDif = difX + nodeSizeDifference / 2
            let nextY = curY + treeSizeDifference
            
            let start = CGPoint(x: midX - difX, y: curY)
            let end = CGPoint(x: midX + nextDif, y: nextY)
            let mid = CGPoint(x: start.x, y: end.y)
            
            var previous: UILabel!
            
            let dif = 1 / CGFloat(i + i / 2 + 1)
            var percentage = CGFloat(0)
            while percentage <= 1 {
                
                let point = getBezierPoint(start: start, end: end, mid: mid, percentage: percentage)
                
                let label = createNode(x: point.x, y: point.y, size: nodeSize / 1.5, color: getRandomDecorationColor(), text: getRandomDecorationText())
                decorasions.append(label)
                label.layer.borderColor = UIColor.white.cgColor
                label.alpha = 0.0
                AnimationManager.addAnimation(animation: {
                    label.alpha = 1.0
                }, completion: nil, duration: 0.0001, type: .animation, description: nil)
                self.view.addSubview(label)
                
                if previous != nil {
                    connectNodes(from: CGPoint(x: label.frame.midX, y: label.frame.midY), to: CGPoint(x: previous.frame.midX, y: previous.frame.midY), color: .red, isDashed: true)
                }
                percentage += dif
                
                previous = label
            }
            
            curY = nextY
            difX = nextDif
        }
    }
    
    private func connectNodes(from: CGPoint, to: CGPoint, color: UIColor, isDashed: Bool = false) {
        let path = UIBezierPath()
        
        path.move(to: from)
        path.addQuadCurve(to: to, controlPoint: CGPoint(x: to.x, y: from.y))
        
        let layer = CAShapeLayer()
        layer.strokeColor = color.cgColor
        layer.fillColor = nil
        layer.path = path.cgPath
        layer.lineWidth = lineWidth
        layer.zPosition = -1
        if isDashed {
            layer.lineDashPattern = [0, NSNumber(value: Float(lineWidth * 4))]
            layer.lineCap = kCALineCapRound
            layer.zPosition = 0
        }
        
        self.view.layer.addSublayer(layer)
    }
    
    private func buildTree() {
        var curX = self.view.frame.midX - nodeSize / 2
        var curY: CGFloat = 120
        
        var treeNodes = [[UILabel]]()
        
        for i in 0..<7 {
            var line = [UILabel]()
            var animations = [() -> Void]()
            for j in 0...i {
                let label = createTreeNode(x: curX, y: curY)
                label.alpha = 0.0
                animations.append({label.alpha = 1.0})
                self.view.addSubview(label)
                line.append(label)
                curX += nodeSizeDifference
                
                
                if i == 0 {
                    continue
                }
                if j != i {
                    connectNodes(from: CGPoint(x: label.frame.midX, y: label.frame.midY), to: CGPoint(x: treeNodes[i - 1][j].frame.midX, y: treeNodes[i - 1][j].frame.midY), color: .green)
                }
                if j != 0 {
                    connectNodes(from: CGPoint(x: label.frame.midX, y: label.frame.midY), to: CGPoint(x: treeNodes[i - 1][j - 1].frame.midX, y: treeNodes[i - 1][j - 1].frame.midY), color: .green)
                }
            }
            AnimationManager.addAnimation(animation: {
                AnimationManager.defaultDuration = 0.25
            }, completion: nil, duration: 1, type: .none, description: nil)
            AnimationManager.addAnimation(animation: {
                for animation in animations {
                    animation()
                }
            }, completion: nil, duration: 0.1, type: .animation, description: nil)
            treeNodes.append(line)
            curY += treeSizeDifference
            curX = self.view.frame.midX - CGFloat((i + 1) / 2) * nodeSizeDifference - nodeSize / 2
            if i % 2 == 0 {
                curX -= nodeSizeDifference / 2
            }
        }
        curY -= nodeOffset
        curX = self.view.frame.midX - nodeSize / 2
        let label = createNode(x: curX, y: curY, size: nodeSize, color: .brown, text: nil)
        label.layer.cornerRadius = 0
        label.alpha = 0.0
        self.view.addSubview(label)
        AnimationManager.addAnimation(animation: {
            label.alpha = 1.0
        }, completion: nil, duration: 0.1, type: .animation, description: nil)
    }
    
    private func createTreeNode(x: CGFloat, y: CGFloat) -> UILabel {
        return createNode(x: x, y: y, size: nodeSize, color: .green, text: nil)
    }
    
    private func createNode(x: CGFloat, y: CGFloat, size: CGFloat, color: UIColor, text: String?) -> UILabel {
        let label = UILabel(frame: CGRect(x: x, y: y, width: size, height: size))
        label.text = text
        label.font = label.font.withSize(fontSize)
        label.textAlignment = .center
        label.layer.backgroundColor = color.cgColor
        label.layer.cornerRadius = size / 2
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = lineWidth
        
        return label
    }
    
}
