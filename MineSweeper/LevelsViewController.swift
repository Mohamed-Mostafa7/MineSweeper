//
//  ViewController.swift
//  MineSweeper
//
//  Created by Mohamed Mostafa on 21/05/2021.
//

import UIKit

class LevelsViewController: UIViewController {
    
    var numberOfRows = 0
    var numberOfColumns = 0
    var numberOfBombs = 0
    
    @IBOutlet var easyButton: UIButton!
    @IBOutlet var mediumButton: UIButton!
    @IBOutlet var hardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Choose Level"
        navigationController?.navigationBar.barTintColor = .lightGray
        navigationController?.navigationBar.tintColor = .black
        view.backgroundColor = .lightGray
        editButton(button: easyButton)
        editButton(button: mediumButton)
        editButton(button: hardButton)
    }
    
    @IBAction func levelButtonTapped(_ sender: UIButton) {
        
        if sender.tag == 0 {
            numberOfRows = 15
            numberOfColumns = 7
            numberOfBombs = 30
        } else if sender.tag == 1 {
            numberOfRows = 20
            numberOfColumns = 11
            numberOfBombs = 45
        } else {
            numberOfRows = 25
            numberOfColumns = 13
            numberOfBombs = 150
        }
        
        if let vc = storyboard?.instantiateViewController(identifier: "Game") as? GameViewController {
            vc.numberOfRows = numberOfRows
            vc.numberOfColumns = numberOfColumns
            vc.numberOfBombs = numberOfBombs
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func editButton(button: UIButton) {
        button.contentEdgeInsets = UIEdgeInsets(top: 5,left: 20,bottom: 5,right: 20)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5
    }
    
}

