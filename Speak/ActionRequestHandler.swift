//
//  ActionRequestHandler.swift
//  Speak
//
//  Created by Daniel Dadap on 3/30/18.
//  Copyright © 2018 Daniel Dadap. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    var extensionContext: NSExtensionContext?

    func beginRequest(with context: NSExtensionContext) {
        self.extensionContext = context

        for item in extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { (data, error) -> Void in
                        if let text = data as? String {
                            var rate : Float = 1.5
                            if let defaults = UserDefaults(suiteName: "group.org.tlhInganHol.iOS.klingonttsengine") {
                                let defaultsRate = defaults.float(forKey: "rate")
                                if (defaultsRate != 0) {
                                    rate = defaultsRate
                                }
                            }
                            let tts = KlingonTTS(text, rate: rate)
                            tts.say()
                            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
                        }
                    })

                }
            }
        }
    }
}
