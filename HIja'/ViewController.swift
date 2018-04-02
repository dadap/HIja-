//
//  ViewController.swift
//  HIja'
//
//  Created by Daniel Dadap on 3/29/18.
//  Copyright © 2018 Daniel Dadap. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var inputText : UITextField!
    @IBOutlet weak var rateSlider : UISlider!

    @IBAction func speak (_ sender: AnyObject) {
        let tts = KlingonTTS(inputText.text!, rate: rateSlider.value)
        tts.say()
    }

    @IBAction func phraseButton (_ sender: UIButton) {
        let tts = KlingonTTS(sender.titleLabel!.text!, rate: rateSlider.value)
        tts.say()
    }

    @IBAction func enterPressed(_ sender: AnyObject) {
        speak(sender)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

