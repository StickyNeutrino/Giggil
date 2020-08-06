//
//  SwitchView.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 6/14/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import UIKit

class SwitchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = SwitchView()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        
        swipeRight.direction = .right
        swipeLeft.direction = .left
        
        
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeLeft)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    @objc func swipedLeft(_ recognizer : UISwipeGestureRecognizer) {
        if recognizer.state == .recognized {
            (view as! SwitchView).mainSwitch.selectedSegmentIndex = 0
            (view as! SwitchView).segmentChanged()
        }
    }
    
    @objc func swipedRight(_ recognizer : UISwipeGestureRecognizer) {
        if recognizer.state == .recognized {
            (view as! SwitchView).mainSwitch.selectedSegmentIndex = 1
            (view as! SwitchView).segmentChanged()
        }
    }
    
    var rightVC : UIViewController? {
        
        get {
            return (view as! SwitchView).rightView
        }
        
        set(child) {
           
            rightVC?.removeFromParent()
            
            (view as! SwitchView).rightView = child
            
            addChild(child!)
            child!.didMove(toParent: self)
            
            (view as! SwitchView).segmentChanged()
        }
    }
    
    var leftVC : UIViewController? {
        
        get {
            return (view as! SwitchView).leftView
        }
        
        set(child) {
            
            leftVC?.removeFromParent()
            
            (view as! SwitchView).leftView = child
            
            addChild(child!)
            child!.didMove(toParent: self)
            
            (view as! SwitchView).segmentChanged()
        }
    }
    
    var leftButton : UIButton {
        
        get {
            
            return (view as! SwitchView).leftButton
        }
    }
    
    var rightButton : UIButton {
        get {
    
            return (view as! SwitchView).rightButton
        }
    }
    
    func setSegmentNames(names : [String]){
        
        let segmentControl = (view as! SwitchView).mainSwitch
        
        var i = 0;
        
        for name in names {
            segmentControl.setTitle(name, forSegmentAt: i)
            
            i += 1
        }
    }
}
