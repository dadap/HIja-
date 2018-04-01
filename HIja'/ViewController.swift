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

    @IBAction func speak (_ sender: AnyObject) {
        let tts = KlingonTTS(inputText.text!)
        tts.say()
    }

    @IBAction func phraseButton (_ sender: UIButton) {
        let tts = KlingonTTS(sender.titleLabel!.text!)
        tts.say()
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

