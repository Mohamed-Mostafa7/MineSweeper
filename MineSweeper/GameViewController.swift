//
//  GameViewController.swift
//  MineSweeper
//
//  Created by Mohamed Mostafa on 21/05/2021.
//

import UIKit

class GameViewController: UIViewController {
    var numberOfRows: Int?
    var numberOfBombs: Int?
    var numberOfColumns: Int?
    var buttons = [UIButton]()
    let buttonsView = UIView()
    var navigationBarHeight: CGFloat = 0.0
    var bombsArray = [Bool]()
    
    // MARK: - Create ButtonsView
    override func loadView() {
        view = UIView ()
        view.backgroundColor = .gray

        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.backgroundColor = .lightGray
        view.addSubview(buttonsView)

        NSLayoutConstraint.activate([

            buttonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsView.widthAnchor.constraint(equalTo: view.widthAnchor)

        ])

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidLayoutSubviews() {
        // MARK: - Add The Buttons To The ButtonsView
        
        guard let c = numberOfColumns, let r = numberOfRows else { return }
        let width = view.frame.size.width  / CGFloat(c)
        let height = buttonsView.frame.size.height / CGFloat(r)
        if let row = numberOfRows, let column = numberOfColumns {
            var tag = 0
            for row in 0..<row {
                for column in 0..<column {
                    let explodingButton = UIButton(type: .system)
                    explodingButton.setTitle("", for: .normal)
                    explodingButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

                    let frame = CGRect(x: column * Int(width), y: row * Int(height), width: Int(width), height: Int(height))
                    explodingButton.frame = frame
                    explodingButton.layer.borderWidth = 1
                    explodingButton.layer.borderColor = UIColor.gray.cgColor
                    explodingButton.layer.cornerRadius = width / 10
                    explodingButton.backgroundColor = tag % 2 == 0 ? .gray : .lightGray
                    explodingButton.layer.shadowOpacity = 1.0
                    explodingButton.layer.shadowColor = UIColor.white.cgColor
                    explodingButton.tag = tag
                    tag += 1
                    
                    buttonsView.addSubview(explodingButton)
                    buttons.append(explodingButton)
                }
            }
        }
        addBombs()
    }
    
    // MARK: - buttonTapped
    
    @objc func buttonTapped(_ sender: UIButton) {
        let button = buttons[sender.tag]
        button.isEnabled = false
        
        if bombsArray[button.tag] == true {
            button.backgroundColor = .red
            button.setTitle("💣", for: .normal)
            gameOver()
        } else {
            CheckNeighbors(buttonTag: button.tag)
            button.backgroundColor = button.tag %  2 == 0 ? .white :  UIColor(red: 250/255, green: 230/255, blue: 243/255, alpha: 1)
        }
        
        button.layer.cornerRadius = 0
    }
    
    // MARK: - Adding Bombs Func
    func addBombs() {
        bombsArray.removeAll()
        for _ in 0..<(buttons.count - (numberOfBombs ?? 0)) {
            bombsArray.append(false)
        }
        for _ in 0..<(numberOfBombs ?? 0) {
            bombsArray.append(true)
        }
        bombsArray.shuffle()
        
        print(bombsArray.count)
    }
    
    // MARK: - When Game Is Over
    func gameOver(){
        let ac = UIAlertController(title: "Game Over", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
            self.restart()
        }))
        ac.addAction(UIAlertAction(title: "Choose Level", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        
        present(ac, animated: true)
    }
    
    // MARK: - Restart Func
    func restart() {
        for button in buttons {
            button.isEnabled = true
            button.backgroundColor = button.tag %  2 == 0 ? .gray : .lightGray
            button.setTitle("", for: .normal)
            bombsArray.shuffle()
        }
    }
    
    // MARK: - Check neiboughrs
    func CheckNeighbors(buttonTag: Int) {
        guard let columnNumber = numberOfColumns else { return }
        var neighbors = [Int]()
        
        let nextLine = buttonTag + columnNumber
        let previousLine = buttonTag - columnNumber
    
        func disable(button: UIButton) {
            button.backgroundColor = .white
        }
        
        if (buttonTag + 1) % columnNumber == 1 {

            if buttonTag == 0 {
                neighbors = [buttonTag + 1, nextLine, nextLine + 1]
            }else if ((buttonTag + columnNumber) == buttons.count)  {
                neighbors = [buttonTag + 1, previousLine, previousLine + 1]
            } else {
                neighbors = [buttonTag + 1, nextLine, nextLine + 1, previousLine, previousLine + 1]
            }

        }else if (buttonTag + 1) % columnNumber == 0 {
            
            if (buttonTag + 1) == columnNumber {
                neighbors = [buttonTag - 1, nextLine, nextLine - 1]
            }else if (buttonTag + 1) == buttons.count {
                neighbors = [buttonTag - 1, previousLine, previousLine - 1]
            } else {
                neighbors = [buttonTag - 1, nextLine, nextLine - 1, previousLine, previousLine - 1]
            }
            
        } else {
            neighbors = [buttonTag + 1, buttonTag - 1, nextLine, nextLine + 1, nextLine - 1, previousLine, previousLine + 1, previousLine - 1]
        }
        
        
        for i in neighbors {
            disable(button: buttons[i])
//            buttonTapped(buttons[i])
        }
    }
}
