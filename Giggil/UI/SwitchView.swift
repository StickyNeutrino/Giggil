//
//  SwitchView.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 6/14/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation

import UIKit

class SwitchView : UIView {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor(named: "SumBlue")!
        
        layoutViews()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var rightView : UIViewController?
    
    var leftView : UIViewController?
    
    let topBar : UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor(named: "SumBlue")!
        
        return view
    }()
    
    let rightButton = UIButton()
    
    let leftButton = UIButton()
    
    let mainSwitch : UISegmentedControl = {
        let control = UISegmentedControl(items: ["Zero","One"])
        
        control.selectedSegmentIndex = 1
        
        control.layer.cornerRadius = 20.0
        control.layer.borderWidth = 3.0
        control.layer.borderColor = UIColor(named: "DarkBlue")!.cgColor
        control.layer.masksToBounds = true
        
        control.backgroundColor = UIColor(named: "DarkBlue")!
        
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor(named: "DarkBlue")!], for: .selected)
        
        control.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 20, weight: .bold)], for: .normal)
        control.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 20, weight: .bold)], for: .selected)
        
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        control.tintColor = UIColor(white: 1, alpha: 0.8)
        
        return control
    }()
    
    let displayArea : UIView = {
        let newView = UIView()
        
        newView.layer.cornerRadius = 25.0
        newView.layer.masksToBounds = true
        
        newView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        return newView
    }()
    
    func layoutViews(){
        addSubview(topBar)
        
        quickLayout(main: topBar, other: self, constraints:
            [("left", "left", 0),
             ("right", "right", 0),
             ("top", "top", 8),
             ("height", "none", 80)
            ])
        
        
        topBar.addSubview(mainSwitch)
        
        quickLayout(main: mainSwitch, other: topBar, constraints:
            [("x", "x", 0),
             ("y", "y", 5),
             ("width", "none", 250),
             ("height", "none", 40)
            ])
        
        
        topBar.addSubview(rightButton)
        
        quickLayout(main: rightButton, other: topBar, constraints:
            [("right", "right", -20),
             ("y", "y", 5),
             ("width", "none", 40),
             ("height", "none", 40)
            ])
        
        
        topBar.addSubview(leftButton)
        
        quickLayout(main: leftButton, other: topBar, constraints:
            [("left", "left", 20),
             ("y", "y", 5),
             ("width", "none", 40),
             ("height", "none", 40)
            ])
        
        addSubview(displayArea)
        
        displayArea.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        
        quickLayout(main: displayArea, other: self, constraints:
            [("bottom", "bottom", 0),
             ("left", "left", 0),
             ("right", "right", 0),
            ])
        
    }
    
    @objc func segmentChanged(){
        
        for subview in displayArea.subviews {
            subview.removeFromSuperview()
        }
        
        if mainSwitch.selectedSegmentIndex == 1 {
            if rightView != nil{
                displayArea.addSubview(rightView!.view)
            }
            
        }else{
            if leftView != nil{
                displayArea.addSubview(leftView!.view)
            }
        }
        
        for subview in displayArea.subviews {
            quickLayout(main: subview, other: displayArea, constraints:
                [("top", "top", 0),
                 ("bottom", "bottom", 0),
                 ("left", "left", 0),
                 ("right", "right", 0),
                ])
            
        }
    }
}
