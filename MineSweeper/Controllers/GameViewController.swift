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
    var remainingBombsNumber = 0 {
        didSet {
            bombsLabel.text = "\(remainingBombsNumber) 💣"
        }
    }
    var numberOfColumns: Int?
    var smashedBombsCounter = 0
    var buttons = [UIButton]()
    let buttonsView = UIView()
    var bombsArray = [Bool]()
    var touchedBombs = [Int]()
    var gameTimer: Timer?
    
    var bombsLabel = UILabel()
    // this is the timer count
    var secondsCounter = 0
    
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
        remainingBombsNumber = numberOfBombs ?? 0
        startTimer()
        
        // MARK: - navigationBar items
        if let navigationBar = self.navigationController?.navigationBar {
            let remainingBombs = CGRect(x: navigationBar.frame.width - 60, y: 0, width: 60, height: navigationBar.frame.height)

            bombsLabel = UILabel(frame: remainingBombs)
            bombsLabel.textAlignment = .center
            bombsLabel.text = "\(remainingBombsNumber) 💣"
            title = "00:00"

            navigationBar.addSubview(bombsLabel)
        }
        
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
                    explodingButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                    explodingButton.addTarget(self, action: #selector(buttonDraged(_:)), for: .touchDragExit)
                    
                    let frame = CGRect(x: column * Int(width), y: row * Int(height), width: Int(width), height: Int(height))
                    explodingButton.frame = frame
                    explodingButton.setTitle("", for: .normal)
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        gameTimer?.invalidate()
        bombsLabel.removeFromSuperview()
    }
    
    
    func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.secondsCounter += 1
            let seconds = self.secondsCounter%60
            let minutes = self.secondsCounter/60
            var stringSeconds = "\(seconds)"
            var stringMinutes = "\(minutes)"
            
            stringSeconds = seconds < 10 ? "0\(seconds)" : stringSeconds
            stringMinutes = minutes < 10 ? "0\(minutes)" : stringMinutes
            self.title = "\(stringMinutes):\(stringSeconds)"
        }
    }

    @objc func buttonDraged(_ sender: UIButton) {
        
        if sender.currentTitle == "" {
            if remainingBombsNumber == 0 {
                let ac = UIAlertController(title: "Be carful ‼", message: "you have already used all the mark", preferredStyle: .alert)
                let Ok = UIAlertAction(title: "Ok", style: .default)
                ac.addAction(Ok)
                present(ac, animated: true)
                return
            }
            sender.setTitle("🚩", for: .normal)
            remainingBombsNumber -= 1
        } else {
            sender.setTitle("", for: .normal)
            remainingBombsNumber += 1
        }
        
    }
    
    // MARK: - buttonTapped
    
    @objc func buttonTapped(_ sender: UIButton) {
        print(sender.currentTitle ?? "blablabla")
        guard sender.currentTitle != "🚩" else {return}
        let button = buttons[sender.tag]
        
        // in first click
        if smashedBombsCounter == 0 {
            firstClick(buttonTag: button.tag)
        }
        
        // check if it's a bomb or not
        if bombsArray[button.tag] == true {
            for i in 0..<bombsArray.count {
                if bombsArray[i] == true {
                    if buttons[i].currentTitle != "🚩" {
                        buttons[i].backgroundColor = .yellow
                        buttons[i].setTitle("💣", for: .normal)
                    }
                }else {
                    if buttons[i].currentTitle == "🚩" {
                        buttons[i].setTitle("❌", for: .normal)
                    }
                }
            }
            button.backgroundColor = .red
            button.setTitle("💣", for: .normal)
            
            gameOver(title: "You Lost 😵")
            bombsLabel.text = "😵"
        } else {
            explodeButton(button: button)
        }
        
        button.layer.cornerRadius = 0
    }
    
    // MARK: - explode func
    // this func is to find explode the neighor of a button if it has no touched bomb
    // and explode only the button if it has touched bomb
    func explodeButton(button: UIButton) {
        guard button.currentTitle != "🚩" else {return}
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
    
    // MARK: - smash func
    // disable the button and add the number of touched bombs to it
    func smash(button: UIButton) {
        guard button.isEnabled else { return }
        smashedBombsCounter += 1
        button.isEnabled = false
        button.backgroundColor = button.tag %  2 == 0 ? .white :  UIColor(red: 250/255, green: 230/255, blue: 243/255, alpha: 1)
        
        // add the number of touched bombs with special color
        switch touchedBombs[button.tag] {
        case 0:
            button.setTitle("", for: .normal)
        case 1:
            button.setTitle("\(touchedBombs[button.tag])", for: .normal)
            button.setTitleColor(.blue, for: .normal)
        case 2:
            button.setTitle("\(touchedBombs[button.tag])", for: .normal)
            button.setTitleColor(.orange, for: .normal)
        case 3,4:
            button.setTitle("\(touchedBombs[button.tag])", for: .normal)
            button.setTitleColor(.brown, for: .normal)
        default:
            button.setTitle("\(touchedBombs[button.tag])", for: .normal)
            button.setTitleColor(.red, for: .normal)
        }
        
        if smashedBombsCounter == buttons.count - (numberOfBombs ?? 0) {
            gameOver(title: "Congratulations You Won 🥳")
            bombsLabel.text = "😃"
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
        
    }
    
    // MARK: - When Game Is Over
    func gameOver(title: String){
        gameTimer?.invalidate()
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
        secondsCounter = -1
        remainingBombsNumber = numberOfBombs ?? 0
        startTimer()
        for button in buttons {
            button.isEnabled = true
            button.backgroundColor = button.tag %  2 == 0 ? .gray : .lightGray
            button.setTitle("", for: .normal)
            bombsArray.shuffle()
        }
        smashedBombsCounter = 0
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
    // In the first click the clicked button must contain no bomb inside or the and the touching buttons as well.
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
