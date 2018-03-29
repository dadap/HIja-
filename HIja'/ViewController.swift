//
//  ViewController.swift
//  HIja'
//
//  Created by Daniel Dadap on 3/29/18.
//  Copyright © 2018 Daniel Dadap. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func speak (_ sender: AnyObject) {
        let tts = KlingonTTS(["qa0", "maz", "puz", "jon", "taz", "neh"])
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

