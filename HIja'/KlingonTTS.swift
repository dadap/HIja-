//
//  KlingonTTS.swift
//  HIja'
//
//  Created by Daniel Dadap on 3/29/18.
//  Copyright © 2018 Daniel Dadap. All rights reserved.
//

import UIKit
import AVKit

class KlingonTTS: NSObject {
    enum TTSError : Error {
        case assetNotFound
    }

    private var player: AVAudioPlayer?
    private var phrase: [NSDataAsset]!
    private var rate : Float

    init(_ syllables: [String], rate : Float = 1.0) {
        phrase = []
        for syllable in syllables {
            let assetName = "audio_" + syllable
            phrase.append(NSDataAsset(name: assetName)!)
        }
        self.rate = rate
        super.init()
    }

    func say() {
        var i = 0;
        while (i < phrase.count) {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                player = try AVAudioPlayer(data: phrase[i].data, fileTypeHint: AVFileType.mp3.rawValue)
                player?.rate = rate
                player?.enableRate = true
                player?.play()
                // XXX figure out why delegate audioPlayerDidFinishPlaying isn't working and use that instead
                while (player != nil && (player?.isPlaying)!) {
                    usleep(5)
                }
            } catch {
                print("error")
            }
            i = i + 1
        }
    }
}
