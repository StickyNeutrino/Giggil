//
//  SettingsView.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 12/27/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import UIKit
import MTSlideToOpen

class SettingsView: UIView {
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor(named: "DarkBlue")!
        
        nameField.delegate = self
        
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let topLabel: UILabel = {
        let label = UILabel()
        
        let text = NSAttributedString(
                   string: "Settings",
                   attributes:
                       [.font:
                           UIFont.systemFont(
                               ofSize: 30,
                               weight: .bold)
                       ])
        
        label.attributedText = text
        
        label.textColor = .white
        
        return label
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        
        let text = NSAttributedString(
            string: "done",
            attributes:
                [.font:
                    UIFont.systemFont(
                        ofSize: 30,
                        weight: .bold)
                ])
        
        button.setAttributedTitle(text, for: .normal)

        button.titleLabel?.textColor = .white
        
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        
        let text = NSAttributedString(
            string: "cancel",
            attributes:
                [.font:
                    UIFont.systemFont(
                        ofSize: 30,
                        weight: .bold)
                ])
        
        button.setAttributedTitle(text, for: .normal)

        button.titleLabel?.textColor = .white
        
        return button
    }()
    
//    let deleteSlider: MTSlideToOpenView = {
//        let slider = MTSlideToOpenView()
//
//        slider.slidingColor = UIColor(white: 1.0, alpha: 0.6)
//        slider.textColor = .white
//
//        slider.sliderBackgroundColor = UIColor(white: 1.0, alpha: 0.2)
//
//        slider.sliderCornerRadius = 5
//        slider.sliderViewTopDistance = 0
//
//        slider.labelText = "delete account"
//        slider.textLabel.font = .systemFont(ofSize: 20, weight: .bold)
//
//
//        slider.thumnailImageView.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
//        slider.thumnailImageView.image = UIImage(named: "BackArrow")?
//            .withHorizontallyFlippedOrientation()
//            .withRenderingMode(.alwaysTemplate)
//
//        slider.thumnailImageView.layer.cornerRadius = 5
//
//
//        slider.thumnailImageView.tintColor = UIColor(named: "DarkBlue")
//        slider.thumnailImageView.contentMode = .scaleAspectFit
//
//        slider.backgroundColor = .clear
//
//        return slider
//    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Profile Name"
        
        label.textColor = .white
        
        return label
    }()
    
    let nameField: UITextField = {
        let field = UITextField()
        
        field.backgroundColor = .white
        
        field.placeholder = "Unknown User"
        
        field.textAlignment = .center
        
        field.layer.cornerRadius = 5
        
        field.clipsToBounds = true
        
        return field
    }()
    
    func layoutViews(){
        addSubview(topLabel)
        quickLayout(main: topLabel, other: self, constraints:
            [("top", "top", 20),
             ("x", "x", 0)
            ])
        
        addSubview(nameLabel)
        quickLayout(main: nameLabel, other: topLabel, constraints:
            [("top", "bottom", 20),
             ("x", "x", 0)
            ])
        
        addSubview(nameField)
        quickLayout(main: nameField, other: self, constraints:
            [("x", "x", 0),
             ("width", "width", -60),
             ("height", "none", 40)
            ])
        
        quickLayout(main: nameField, other: nameLabel, constraints:
            [("top", "bottom", 10)])
//
//        addSubview(deleteSlider)
//        quickLayout(main: deleteSlider, other: self, constraints:
//            [("bottom", "bottom", -100) ,
//             ("width", "width", -60),
//             ("height", "none", 40),
//             ("x", "x", 0)
//            ])
        
        addSubview(doneButton)
        quickLayout(main: doneButton, other: self, constraints:
            [("bottom", "bottom", -20),
             ("left", "x", 25)
            ])
        
        addSubview(cancelButton)
        quickLayout(main: cancelButton, other: self, constraints:
            [("bottom", "bottom", -20),
             ("right", "x", -25)
            ])
    }
}

extension SettingsView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
