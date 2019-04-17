//
//  ViewController.swift
//  Evil Hangman
//
//  Created by Kim, David on 4/15/19.
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
    @IBOutlet weak var guessedLetterLabel: UILabel!
    
    var lettersGuessed = ""
    let maxNumberOfWrongGuesses = 14
    var WrongGuessesRemaining = 14
    var guessCount = 0
    var availableWords: [String] = []
    var wordToGuess = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDictionary(availableWords: &availableWords)
        formatUserGuessLabel()
       // print(wordToGuess)
        guessLetterButton.isEnabled = false
        playAgainButton.isHidden = true
    }

    func initializeDictionary(availableWords: inout [String]){
        //reading from dictionary file
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
//        wordToGuess = availableWords.randomElement()!
//        wordToGuess = wordToGuess.uppercased()
    }

    func formatUserGuessLabel(){
        var revealedWord = ""
        wordToGuess = availableWords.randomElement()!
        lettersGuessed += (guessedLetterField.text?.lowercased())!
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
    
    func findWordFamily()-> [String]{
        
        print(availableWords)
        
        var wordFamily:[String] = []
        let guess = guessedLetterField.text!.lowercased()
        for word in availableWords{
            var progress = ""
            for letter in word{
                if(String(letter) == guess){
                    progress += guess
                } else {
                    progress += "_"
                }
            }
            wordFamily.append(progress)
        }
        //print(wordFamily)
        return wordFamily
    }
    
    func guessALetter(){
        let wordFamilies = findWordFamily()
       
        //find most common world family
        var counts = [String: Int]()
        wordFamilies.forEach{ counts[$0] = (counts[$0] ?? 0) + 1 }
        if let (groupToReturn, count) = counts.max(by: {$0.1 < $1.1}){
            print("\(groupToReturn) occurs \(count) times")
            
            //update availableWords
            let guess = guessedLetterField.text!.lowercased()
            var updatedAvailableWords: [String] = []
            for word in availableWords{
                var wordFamily = ""
                for letter in word{
                    if(String(letter) == guess){
                        wordFamily += guess
                    }else{
                        wordFamily += "_"
                    }
                }
                if(wordFamily == groupToReturn){
                    updatedAvailableWords.append(word)
                }
            }
            availableWords = updatedAvailableWords
        }
        
        formatUserGuessLabel()
        guessCount += 1
        print("wordToGuess = \(wordToGuess)")
        let currentLetterGuessed = (guessedLetterField.text?.lowercased())!
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
            var finalWord = ""
            for letter in wordToGuess{
                finalWord += " " + String(letter)
            }
            userGuessLabel.text = finalWord
            guessCountLabel.text = "So sorry, you're all out of guesses. Try again?"
        } else if !revealedWord.contains("_"){
            playAgainButton.isHidden = false
            guessedLetterField.isEnabled = false
            guessLetterButton.isEnabled = false
            guessCountLabel.text = "You've got it! It took you \(guessCount) Guesses to Guess the word!"
        } else {
            let guess = (guessCount == 1 ? "Guess" : "Guesses")
            guessCountLabel.text = "You Have \(WrongGuessesRemaining) \(guess) Remaining"
        }
    }
    
    func updateGuessedLetterLabel(){
        var lettersGuessedFormated = ""
        for letter in lettersGuessed{
            lettersGuessedFormated += (" " + String(letter))
        }
        guessedLetterLabel.text = lettersGuessedFormated
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
        updateGuessedLetterLabel()
        updateUIAfterGuess()
    }
    
    
    @IBAction func playAgainButtonPressed(_ sender: UIButton) {
        initializeDictionary(availableWords: &availableWords)
        playAgainButton.isHidden = true
        guessedLetterField.isEnabled = true
        guessLetterButton.isEnabled = false
        hangmanImageView.image = UIImage(named: "Picture14")
        WrongGuessesRemaining = maxNumberOfWrongGuesses
        guessedLetterLabel.text = ""
        lettersGuessed = ""
        formatUserGuessLabel()
        guessCountLabel.text = "You've Made 0 Guesses"
        guessCount = 0
    }
    
}

