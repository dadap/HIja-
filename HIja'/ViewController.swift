//
//  ViewController.swift
//  HIja'
//
//  Created by Daniel Dadap on 3/29/18.
//  Copyright © 2018 Daniel Dadap. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var defaults : UserDefaults!

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

    @IBAction func rateChanged(_ sender: UISlider) {
        defaults.set(sender.value, forKey: "rate")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        defaults = UserDefaults(suiteName: "group.org.tlhInganHol.iOS.klingonttsengine")

        let rate = defaults.float(forKey: "rate")
        if (rate != 0) {
            rateSlider.value = rate
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

