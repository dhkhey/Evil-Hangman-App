//
//  ViewController.swift
//  Evil Hangman
//
//  Created by Kim, Young-Tae on 4/15/19.
//  Copyright © 2019 David Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var guessLetterButton: UIButton!
    @IBOutlet weak var userGuessLabel: UILabel!
    @IBOutlet weak var guessedLetterField: UITextField!
    @IBOutlet weak var guessCountLabel: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var hangmanImageView: UIImageView!
    
    
    var lettersGuessed = ""
    let maxNumberOfWrongGuesses = 14
    var WrongGuessesRemaining = 14
    var guessCount = 0
    var availableWords: [String] = []
    var wordToGuess = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDictionary(availableWords: &availableWords, wordToGuess: &wordToGuess)
        formatUserGuessLabel()
        print(wordToGuess)
        guessLetterButton.isEnabled = false
        playAgainButton.isHidden = true
    }

    func initializeDictionary(availableWords: inout [String], wordToGuess: inout String){
        //reading from text file
        let fileURLProject = Bundle.main.path(forResource: "dictionary", ofType: "txt")
        var readStringProject = ""
        do {
            readStringProject = try String(contentsOfFile: fileURLProject!, encoding:
                String.Encoding.utf8)
        } catch let error as NSError {
            print("failed to read from project")
            print(error)
        }
        //converting read string into array
        let arrayOfWords = readStringProject.components(separatedBy: .whitespacesAndNewlines)
       
        //randomly choose a wordLength of target word
        let availableLengths = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,28,29]
        let wordLength = availableLengths.randomElement()
        
        //updating availableWords with array of words with chosen length
        for word in arrayOfWords{
            if(wordLength == word.count){
                availableWords.append(word)
            }
        }
        wordToGuess = availableWords.randomElement()!
        wordToGuess = wordToGuess.uppercased()
    }

    func formatUserGuessLabel(){
        var revealedWord = ""
        //let chosenWord = availableWords.randomElement()
        lettersGuessed += guessedLetterField.text!
        for letter in wordToGuess{
            if lettersGuessed.contains(letter){
                revealedWord = revealedWord + " \(letter)"
            }else {
                revealedWord += " _"
            }
        }
        //revealedWord.removeFirst()
        userGuessLabel.text = revealedWord
    }
    
    func guessALetter(){
        formatUserGuessLabel()
        guessCount += 1
        let currentLetterGuessed = guessedLetterField.text!
        if !(wordToGuess.contains(currentLetterGuessed)){
            WrongGuessesRemaining -= 1
            if(WrongGuessesRemaining % 2 == 0){
                hangmanImageView.image = UIImage(named: "Picture\(WrongGuessesRemaining)")
            }
        }
        let revealedWord = userGuessLabel.text!
        if WrongGuessesRemaining == 0{
            playAgainButton.isHidden = false
            guessedLetterField.isEnabled = false
            guessLetterButton.isEnabled = false
            guessCountLabel.text = "So sorry, you're all out of guesses. Try again?"
        } else if !revealedWord.contains("_"){
            playAgainButton.isHidden = false
            guessedLetterField.isEnabled = false
            guessLetterButton.isEnabled = false
            guessCountLabel.text = "You've got it! It took you \(guessCount) Guesses to Guess the word!"
        } else {
            let guess = (guessCount == 1 ? "Guess" : "Guesses")
            guessCountLabel.text = "You've Made \(guessCount) \(guess)"
        }
    }
    
    
    
    func updateUIAfterGuess(){
        guessedLetterField.resignFirstResponder()
        guessedLetterField.text = ""
    }
    
    @IBAction func guessedLetterFieldChanged(_ sender: UITextField) {
        if let letterGuessed = guessedLetterField.text?.last {
            guessedLetterField.text = "\(letterGuessed)"
            guessLetterButton.isEnabled = true
        } else {
            guessLetterButton.isEnabled = false
        }
        
    }
    
    @IBAction func doneKeyPressed(_ sender: UITextField) {
        updateUIAfterGuess()
    }
    
    @IBAction func guessLetterButtonPressed(_ sender: UIButton) {
        guessALetter()
        updateUIAfterGuess()
    }
    
    
    @IBAction func playAgainButtonPressed(_ sender: UIButton) {
        initializeDictionary(availableWords: &availableWords, wordToGuess: &wordToGuess)
        playAgainButton.isHidden = true
        guessedLetterField.isEnabled = true
        guessLetterButton.isEnabled = false
        hangmanImageView.image = UIImage(named: "Picture14")
        WrongGuessesRemaining = maxNumberOfWrongGuesses
        formatUserGuessLabel()
        guessCountLabel.text = "You've Made 0 Guesses"
        guessCount = 0
    }
    
}

