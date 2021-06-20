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
    var counter = 0
    var buttons = [UIButton]()
    let buttonsView = UIView()
    var navigationBarHeight: CGFloat = 0.0
    var bombsArray = [Bool]()
    var touchedBombs = [Int]()
    
    
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
                    
                    // MARK: - long press gesture
                    let longPressGeusture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
                    explodingButton.addGestureRecognizer(longPressGeusture)
                    
                    let frame = CGRect(x: column * Int(width), y: row * Int(height), width: Int(width), height: Int(height))
                    explodingButton.frame = frame
                    explodingButton.layer.borderWidth = 1
                    explodingButton.layer.borderColor = UIColor.gray.cgColor
                    explodingButton.layer.cornerRadius = width / 10
                    explodingButton.backgroundColor = tag % 2 == 0 ? .gray : .lightGray
                    explodingButton.setTitleColor(.red, for: .normal)
                    explodingButton.layer.shadowOpacity = 1.0
                    explodingButton.layer.shadowColor = UIColor.white.cgColor
                    explodingButton.tag = tag
                    tag += 1
                    
                    buttonsView.addSubview(explodingButton)
                    buttons.append(explodingButton)
                }
            }
        }
    }
    
    // MARK: - long tap
    
    @objc func longPress(_ guesture: UILongPressGestureRecognizer, _ sender: UIButton) {
        
        if guesture.state == UIGestureRecognizer.State.began {
            print("Long Press")
            print(sender.tag)
//            buttons[sender.tag].isEnabled = false
            
        }
    }
    // MARK: - buttonTapped
    
    @objc func buttonTapped(_ sender: UIButton) {
        let button = buttons[sender.tag]
        
        // in first click
        if counter == 0 {
            firstClick(buttonTag: button.tag)
        }
        
        // check if it's a bomb or not
        if bombsArray[button.tag] == true {
            button.backgroundColor = .red
            button.setTitle("💣", for: .normal)
            gameOver(title: "You Lost 😔")
        } else {
            explodeButton(button: button)
        }
        
        button.layer.cornerRadius = 0
    }
    
    // this func is to find explode the neighor of a button if it has no touched bomb
    // and explode only the button if it has touched bomb
    func explodeButton(button: UIButton) {
        if touchedBombs[button.tag] == 0 {
            smash(button: button)
            let neighbors = CheckNeighbors(buttonTag: button.tag)
            for neighbor in neighbors {
                if buttons[neighbor].isEnabled {
                    explodeButton(button: buttons[neighbor])
                } else {
                    smash(button: buttons[neighbor])
                }
                
            }
        } else {
            smash(button: button)
        }
        
        
    }
    
    // disable the button and add the number of touched bombs to it
    func smash(button: UIButton) {
        guard button.isEnabled else { return }
        counter += 1
        button.isEnabled = false
        button.backgroundColor = button.tag %  2 == 0 ? .white :  UIColor(red: 250/255, green: 230/255, blue: 243/255, alpha: 1)
        
        switch touchedBombs[button.tag] {
        case 0:
            button.setTitle("", for: .normal)
        case 1,2:
            button.setTitle("\(touchedBombs[button.tag])", for: .normal)
            button.setTitleColor(.blue, for: .normal)
        case 3,4:
            button.setTitle("\(touchedBombs[button.tag])", for: .normal)
            button.setTitleColor(.orange, for: .normal)
        default:
            button.setTitle("\(touchedBombs[button.tag])", for: .normal)
            button.setTitleColor(.red, for: .normal)
        }
        
        if counter == buttons.count - (numberOfBombs ?? 0) {
            gameOver(title: "Congratulations You Won 🥳")
        }
        
    }
    
    // MARK: - Adding Bombs Func
    func addBombs(notBombs: Int) {
        bombsArray.removeAll()
        for _ in 0..<notBombs {
            bombsArray.append(false)
        }
        for _ in 0..<(numberOfBombs ?? 0) {
            bombsArray.append(true)
        }
        bombsArray.shuffle()
        
        print(bombsArray.count)
    }
    
    // MARK: - When Game Is Over
    func gameOver(title: String){
        let ac = UIAlertController(title: "\(title)", message: nil, preferredStyle: .alert)
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
        counter = 0
    }
    
    // MARK: - Check neiboughrs
    func CheckNeighbors(buttonTag: Int) -> [Int] {
        guard let columnNumber = numberOfColumns else { return []}
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
            
        } else if (buttonTag + 1) % buttons.count < columnNumber {
            neighbors = [buttonTag + 1, buttonTag - 1, nextLine, nextLine + 1, nextLine - 1]
        } else if (buttonTag + 1) % buttons.count > (buttons.count - columnNumber ) {
            neighbors = [buttonTag + 1, buttonTag - 1, previousLine, previousLine + 1, previousLine - 1]
        } else {
            neighbors = [buttonTag + 1, buttonTag - 1, nextLine, nextLine + 1, nextLine - 1, previousLine, previousLine + 1, previousLine - 1]
        }
        
        return neighbors
        
    }
    
    // MARK: - Add bombs in the first click
    func firstClick(buttonTag: Int) {
        touchedBombs = [Int](repeating: 0, count: buttons.count)
        var neighbors = CheckNeighbors(buttonTag: buttonTag)
        neighbors.append(buttonTag)
        neighbors.sort()
        
        addBombs(notBombs: (buttons.count - (numberOfBombs ?? 0) - neighbors.count))
        for i in neighbors {
            bombsArray.insert(false, at: i)
        }
        touchingBombs()
    }
    func touchingBombs(){
        
        for button in buttons {
            if bombsArray[button.tag] {
                let neighbors = CheckNeighbors(buttonTag: button.tag)
                for neighbor in neighbors {
                    touchedBombs[neighbor] += 1
                }
            }
        }
    }
}
