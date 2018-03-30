//
//  KlingonTTS.swift
//  HIja'
//
//  Created by Daniel Dadap on 3/29/18.
//  Copyright © 2018 Daniel Dadap. All rights reserved.
//

import UIKit
import AVKit

class KlingonTransliterator {
    private class KlingonLetter {
        final var latin : String
        final var xifankQ : String
        final var xifankq : String
        final var pIqaD : String

        init(_ l : String, _ kQ : String, _ kq : String, _ p : String) {
            latin = l
            xifankQ = kQ
            xifankq = kq
            pIqaD = p
        }
    }

    private static let lettertable = [
        KlingonLetter("a", "a", "a", ""),
        KlingonLetter("b", "b", "b", ""),
        KlingonLetter("ch", "c", "c", ""),
        KlingonLetter("D", "d", "d", ""),
        KlingonLetter("e", "e", "e", ""),
        // Temporarily munge "gh" to "G", to prevent "ngh" from becoming "f" instead of "fg".
        KlingonLetter("gh", "G", "G", ""),
        KlingonLetter("H", "h", "h", ""),
        KlingonLetter("I", "i", "i", ""),
        KlingonLetter("j", "j", "j", ""),
        KlingonLetter("l", "l", "l", ""),
        KlingonLetter("m", "m", "m", ""),
        KlingonLetter("n", "n", "n", ""),
        KlingonLetter("ng", "f", "f", ""),
        KlingonLetter("o", "o", "o", ""),
        KlingonLetter("p", "p", "p", ""),
        KlingonLetter("q", "q", "k", ""),
        KlingonLetter("Q", "k", "q", ""),
        KlingonLetter("r", "r", "r", ""),
        KlingonLetter("S", "s", "s", ""),
        KlingonLetter("t", "t", "t", ""),
        KlingonLetter("tlh", "x", "x", ""),
        KlingonLetter("u", "u", "u", ""),
        KlingonLetter("v", "v", "v", ""),
        KlingonLetter("w", "w", "w", ""),
        KlingonLetter("y", "y", "y", ""),
        KlingonLetter("'", "z", "z", ""),
    ]

    enum KlingonScript {
        case latin
        case xifanholkQ
        case xifanholkq
        case pIqaD
    }

    static func transliterate(_ fromString : String, from: KlingonScript = .latin, to: KlingonScript = .xifanholkQ) -> String {
        var ret : String = fromString

        if (from == .xifanholkq || from == .xifanholkQ) {
            // The transliteration table has the munged "G" in the xifan hol entries;
            // munge it back before transliterating from xifan hol
            ret = ret.replacingOccurrences(of: "g", with: "G")
        }

        for letter in lettertable {
            let fromLetter : String
            let toLetter : String

            switch(from) {
            case .latin:
                fromLetter = letter.latin
            case .xifanholkQ:
                fromLetter = letter.xifankQ
            case .xifanholkq:
                fromLetter = letter.xifankq
            case .pIqaD:
                fromLetter = letter.pIqaD
            }

            switch(to) {
            case .latin:
                toLetter = letter.latin
            case .xifanholkQ:
                toLetter = letter.xifankQ
            case .xifanholkq:
                toLetter = letter.xifankq
            case .pIqaD:
                toLetter = letter.pIqaD
            }

            ret = ret.replacingOccurrences(of: fromLetter, with: toLetter)
        }

        if (to == .xifanholkq || to == .xifanholkQ) {
            // Restore 'G' to 'g'
            ret = ret.replacingOccurrences(of: "G", with: "g")
        }

        return ret
    }
}

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
