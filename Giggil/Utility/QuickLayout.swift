//
//  QuickLayout.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 12/24/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import UIKit


func quickLayout(main : UIView, other : UIView, constraints : [(String, String, Double)]){
    
    main.translatesAutoresizingMaskIntoConstraints = false
    
    for constraint in constraints {
        let firstAnchor = [
            "x": main.centerXAnchor,
            "y": main.centerYAnchor,
            "left": main.leftAnchor,
            "right": main.rightAnchor,
            "top": main.topAnchor,
            "bottom": main.bottomAnchor,
            "height": main.heightAnchor,
            "width": main.widthAnchor
            ][constraint.0]
        
        let secondAnchor = [
            "x": other.centerXAnchor,
            "y": other.centerYAnchor,
            "left": other.leftAnchor,
            "right": other.rightAnchor,
            "top": other.topAnchor,
            "bottom": other.bottomAnchor,
            "height": other.heightAnchor,
            "width": other.widthAnchor,
            "none": nil
            ][constraint.1]
        
        if constraint.1 == "none" {
            (firstAnchor as! NSLayoutDimension).constraint(equalToConstant: CGFloat(constraint.2)).isActive = true
            
        }else if ["width", "height"].contains(constraint.0){
            (firstAnchor as! NSLayoutDimension).constraint(equalTo: (secondAnchor as! NSLayoutDimension), constant: CGFloat(constraint.2)).isActive = true
        }else if ["x", "left", "right"].contains(constraint.0){
            (firstAnchor as! NSLayoutXAxisAnchor).constraint(equalTo: (secondAnchor as! NSLayoutXAxisAnchor), constant: CGFloat(constraint.2)).isActive = true
        }else{
            (firstAnchor as! NSLayoutYAxisAnchor).constraint(equalTo: (secondAnchor as! NSLayoutYAxisAnchor), constant: CGFloat(constraint.2)).isActive = true
        }
        
        
    }
}
