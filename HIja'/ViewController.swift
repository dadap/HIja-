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

        NotificationCenter.default.addObserver(self, selector: #selector(externalPhrase), name: .UIApplicationDidBecomeActive, object: nil)
        let rate = defaults.float(forKey: "rate")
        if (rate != 0) {
            rateSlider.value = rate
        }
    }

    @objc func externalPhrase(_ animated: Bool) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if (delegate.phrase != nil) {
                let originalText = inputText.text
                inputText.text = delegate.phrase
                let rate = rateSlider.value

                let tts = KlingonTTS(delegate.phrase!, rate: rate)

                DispatchQueue.global().async {
                    tts.say()
                    delegate.phrase = nil
                    DispatchQueue.main.async {
                        self.inputText.text = originalText

                        if (delegate.caller == "org.tlhInganHol.iOS.flingonassister") {
                            let url = URL(string: "content://org.tlhInganHol.android.klingonassistant.KlingonContentProvider")!
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

