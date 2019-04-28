//
//  ViewController.swift
//  Evil Hangman
//
//  Created by Kim, David on 4/15/19.
//  Copyright © 2019 David Kim. All rights reserved.
//

import UIKit
import AVFoundation

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
    var availableWords: [String] = []
    var wordToGuess = ""
    var audioPlayer = AVAudioPlayer()
    var evilDisabled = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDictionary(availableWords: &availableWords)
        formatUserGuessLabel()
        guessLetterButton.isEnabled = false
        playAgainButton.isHidden = true
    }

    func initializeDictionary(availableWords: inout [String]){
        //read dictionary text file
        let fileURL = Bundle.main.path(forResource: "dictionary", ofType: "txt")
        var readString = ""
        do {
            readString = try String(contentsOfFile: fileURL!, encoding:
                String.Encoding.utf8)
        } catch let error as NSError {
            print("failed to read from file")
            print(error)
        }
        //converting readString into array
        let arrayOfWords = readString.components(separatedBy: .whitespacesAndNewlines)
       
        //randomly choose a wordLength of target word
        let availableLengths = [2,3,4,5,6,7,8,9,10]//[11,12,13,14,15,16,17,18,19,20,21,22,24,28,29]
        let wordLength = availableLengths.randomElement()
        
        //updating availableWords with array of words with chosen length
        for word in arrayOfWords{
            if(wordLength == word.count){
                availableWords.append(word)
            }
        }
    
        wordToGuess = availableWords.randomElement()!

    }

    func formatUserGuessLabel(){
        var revealedWord = ""
        //wordToGuess = availableWords.randomElement()!
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
        //print(availableWords)
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
        return wordFamily
    }
    
    func guessALetter(){
        if evilDisabled == 0{
            let wordFamilies = findWordFamily()
            //find most common world family
            var counts = [String: Int]()
            wordFamilies.forEach{ counts[$0] = (counts[$0] ?? 0) + 1 }
            if let (groupToReturn, count) = counts.max(by: {$0.1 < $1.1}){
                print("\(count) words remaining")
                
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
                wordToGuess = availableWords.randomElement()!
            }
        }
        formatUserGuessLabel()
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
            playSound(soundName: "evilLaugh", audioPlayer: &audioPlayer)
            playAgainButton.isHidden = false
            guessedLetterField.isEnabled = false
            guessLetterButton.isEnabled = false
            var finalWord = ""
            for letter in wordToGuess{
                finalWord += " " + String(letter)
            }
            userGuessLabel.text = finalWord
            guessCountLabel.text = "You Lose! \n The Word Was: \(wordToGuess)"
        } else if !revealedWord.contains("_"){
            playSound(soundName: "angel", audioPlayer: &audioPlayer)
            playAgainButton.isHidden = false
            guessedLetterField.isEnabled = false
            guessLetterButton.isEnabled = false
            guessCountLabel.text = "You Win! Congratulation!"
            hangmanImageView.image = UIImage(named: "angelWin")
        } else {
            let guess = (WrongGuessesRemaining == 1 ? "Guess" : "Guesses")
            guessCountLabel.text = "You Have \(WrongGuessesRemaining) Wrong \(guess) Remaining"
        }
    }
    
    func updateGuessedLetterLabel(){
        var lettersGuessedFormated = ""
        for letter in lettersGuessed{
            lettersGuessedFormated += (String(letter) + "   ")
        }
        guessedLetterLabel.text = lettersGuessedFormated
    }
    
    func updateUIAfterGuess(){
        guessedLetterField.resignFirstResponder()
        guessedLetterField.text = ""
        guessLetterButton.isEnabled = false
    }
    
    func playSound(soundName: String, audioPlayer: inout AVAudioPlayer){
        if let sound = NSDataAsset(name: soundName){
            do {
                try audioPlayer = AVAudioPlayer(data: sound.data)
                audioPlayer.play()
            } catch {
                print("error")
            }
        }else {
            print("Error")
        }
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
        let guess = guessedLetterField.text!.lowercased()
        
        if lettersGuessed.contains(guess){
            guessCountLabel.text = "You Already Guessed the Letter '\(guess)'\n You Have \(WrongGuessesRemaining) Wrong Guesses Remaining"
            updateUIAfterGuess()
        }else if guess == " "{
            guessCountLabel.text = "'\(guess)' is Not a Letter! \n You Have \(WrongGuessesRemaining) Wrong Guesses Remaining"
            updateUIAfterGuess()
            evilDisabled = 1
            print("EvilDisabled = 1")
        }else if !(guess >= "a" && guess <= "z"){
            guessCountLabel.text = "'\(guess)' is Not a Letter! \n You Have \(WrongGuessesRemaining) Wrong Guesses Remaining"
            updateUIAfterGuess()
        }
        else{
            guessALetter()
            updateGuessedLetterLabel()
            updateUIAfterGuess()
        }
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
        evilDisabled = 0
        guessCountLabel.text = "You Have 14 Wrong Guesses Remaining"
    }
    
}

