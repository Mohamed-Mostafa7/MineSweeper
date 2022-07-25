//
//  ViewController.swift
//  MineSweeper
//
//  Created by Mohamed Mostafa on 21/05/2021.
//

import UIKit

class LevelsViewController: UIViewController {
    
    var levelInfo = LevelInfo()
    
    @IBOutlet var easyButton: UIButton!
    @IBOutlet var mediumButton: UIButton!
    @IBOutlet var hardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Choose Level"
        navigationController?.navigationBar.barTintColor = .lightGray
        navigationController?.navigationBar.tintColor = .black
        view.backgroundColor = .lightGray
    }
    
    @IBAction func levelButtonTapped(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            levelInfo.numberOfRows = 15
            levelInfo.numberOfColumns = 7
            levelInfo.numberOfBombs = 10
        case 1:
            levelInfo.numberOfRows = 20
            levelInfo.numberOfColumns = 11
            levelInfo.numberOfBombs = 45
        case 2:
            levelInfo.numberOfRows = 25
            levelInfo.numberOfColumns = 13
            levelInfo.numberOfBombs = 100
        default:
            break
        }
        
        if let vc = storyboard?.instantiateViewController(identifier: "Game") as? GameViewController {
            vc.numberOfRows = levelInfo.numberOfRows
            vc.numberOfColumns = levelInfo.numberOfColumns
            vc.numberOfBombs = levelInfo.numberOfBombs
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

