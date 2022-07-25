//
//  CustomLevelButton.swift
//  MineSweeper
//
//  Created by Mohamed Mostafa on 25/07/2022.
//

import UIKit

class CustomLevelButton: UIButton {
    
    override func awakeFromNib() {
        contentEdgeInsets = UIEdgeInsets(top: 5,left: 20,bottom: 5,right: 20)
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
    }

}
