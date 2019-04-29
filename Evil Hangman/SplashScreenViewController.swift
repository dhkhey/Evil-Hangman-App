//
//
//EVIL HANGMAN.
//ENTER EMPTY SPACE AS GUESS TO TOGGLE OFF EVIL FEATURE.
//
//

import UIKit
import AVFoundation

class SplashScreenViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var evilManImageView: UIImageView!
    
    var audioPlayer = AVAudioPlayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        playSound(soundName: "intro", audioPlayer: &audioPlayer)
        
        let yAtLoad = evilManImageView.frame.origin.y
        evilManImageView.frame.origin.y = view.frame.height
        UIView.animateKeyframes(withDuration: 2.0, delay: 1.0, animations: {self.evilManImageView.frame.origin.y = yAtLoad})
        
        let yAtLoadTitle = titleLabel.frame.origin.y
        titleLabel.frame.origin.y = yAtLoadTitle - 300
        UIView.animateKeyframes(withDuration: 2.0, delay: 4.0, animations: {self.titleLabel.frame.origin.y = yAtLoadTitle})
        
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

    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        audioPlayer.stop()
        performSegue(withIdentifier: "ShowTableView", sender: nil)
    }
}
