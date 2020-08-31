//
//  NearbyUserCell.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 12/30/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import UIKit

class NearbyUserCell: UITableViewCell {
    
    static let identifier = "NearbyUserCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()

        return label
    }()
    
    let idLabel: UITextView = {
        let label = UITextView()

        label.isEditable = false
        
        label.textAlignment = .center
        
        label.textContainerInset = .zero
        
        return label
    }()
    
    let idDescLabel: UILabel = {
        let label = UILabel()

          let text = NSAttributedString(
                  string: "user id",
                  attributes:
                      [.font: UIFont.preferredFont(forTextStyle: .caption1),
                       .foregroundColor: UIColor.gray,
                      ])

        label.attributedText = text
        
        label.textAlignment = .center
        
        return label
    }()
    
    let blockButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .red
        
        return button
    }()
    
    func loadProfile(_ profile: GiggilProfile) {
        self.nameLabel.text = profile.name
        
        var newline = -1
        
        self.idLabel.text = profile.session.id.reduce(String(), { (string, int) -> String in
            newline += 1
            if newline % 8 == 0 && newline != 0 {
                return string + "\n" + String(int)
            } else if newline == 0 {
                return String(int)
            } else {
                return string + " " + String(int)
            }
            })
    }
    
    func setupViews() {
        
        contentView.addSubview(nameLabel)
        quickLayout(main: nameLabel, other: contentView, constraints:
        [("top", "top", 10),
         ("left", "left", 8),
         ("width", "none", 150),
         ("height", "none", 30)
        ])
        
        contentView.addSubview(blockButton)
        quickLayout(main: blockButton, other: nameLabel, constraints:
        [("top", "bottom", 10),
         ("left", "left", 0),
         ("width", "none", 50),
         ("height", "none", 30)
        ])

        contentView.addSubview(idLabel)
        quickLayout(main: idLabel, other: contentView, constraints:
        [("top", "top", 24),
         ("right", "right", -8),
         ("width", "none", 200),
         ("height", "none", 60)
        ])

        contentView.addSubview(idDescLabel)
        quickLayout(main: idDescLabel, other: idLabel, constraints:
        [("bottom", "top", 0),
         ("x", "x", 0),
         ("width", "none", 65),
         ("height", "none", 18)
        ])
        
    }
}

