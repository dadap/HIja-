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

    convenience init(_ phrase: String, rate : Float = 1.0) {
        var syllables : [String] = []
        var normalized = phrase

        // De-smartify single quotes
        normalized = normalized.replacingOccurrences(of: "[‘’]", with: "'", options: .regularExpression)

        // Convert pIqaD and latin to xifan hol
        normalized = KlingonTransliterator.transliterate(normalized, from: .pIqaD, to: .latin)
        normalized = KlingonTransliterator.transliterate(normalized, from: .latin, to: .xifanholkQ)

        // Delete non-alphabetic/whitespace characters
        normalized = normalized.replacingOccurrences(of: "[^a-z\\s]", with: "", options: .regularExpression)

        // Convert all whitespace into spaces
        normalized = normalized.replacingOccurrences(of: "[\\s][\\s]*", with: " ", options: .regularExpression)

        // Split phrase into words and syllabize them
        for word in normalized.split(separator: " ") {
            syllables.append(contentsOf: KlingonTTS.syllabize(word))
        }
        self.init(syllables, rate: rate)

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
                    usleep(10)
                }
            } catch {
                print("error")
            }
            i = i + 1
        }
    }

    private static func isVowel(_ c: Character) -> Bool {
        return "aeiou".contains(c)
    }

    // Break a word into syllables. Returns an array of syllables if the word can be
    // successfully parsed; or an array containing the original input word if it
    // cannot be parsed according to the rules of Klingon phonology.
    // Input is expected to be in xifan hol (k = Q). Output syllables conform with the
    // naming scheme of the audio files.
    private static func syllabize(_ input: Substring) -> [String] {
        var ret : [String] = []
        var i = input.startIndex

        while (i < input.endIndex) {
            // Identify the next candidate syllable with at most four characters
            let distance = input.distance(from: i, to: input.endIndex)
            let end = distance < 4 ? input.endIndex : input.index(i, offsetBy: 4)
            let candidate = input[i ..< end]

            // There shouldn't be any free-floating letters
            if candidate.count < 2 {
                return [String(input)]
            }

            // All Klingon syllables, with the exception of the endearment suffix "-oy",
            // are of the form CV, CVC, or CVCC for some special exceptions
            if isVowel(candidate[candidate.startIndex]) {
                return [String(input)]
            }

            if !isVowel(candidate[candidate.index(candidate.startIndex, offsetBy: 1)]) {
                // TODO "-oy" can occur somewhere other than the end of a word, but in
                // these positions, it will get the final consonant of the preceding
                // syllable as an initial consonant. This is wrong, and should be fixed.
                if (candidate == "oy" && candidate.endIndex == input.endIndex) {
                    ret.append(String(candidate))
                } else {
                    return [String(input)]
                }
            }

            // Handle four-character candidates
            if candidate.count == 4 {
                // If the last character of a four-character candidate is a vowel, then we're
                // probably looking at CVCV.
                if isVowel(candidate[candidate.index(before: candidate.endIndex)]) {
                    ret.append(String(candidate[candidate.startIndex ..< candidate.index(candidate.startIndex, offsetBy: 2)]) + "0")
                    i = input.index(i, offsetBy: 2)
                    continue
                }
                // Allowable consonant clusters in syllable-final position
                if candidate.hasSuffix("rg") || candidate.hasSuffix("wz") || candidate.hasSuffix("yz") {
                    ret.append(String(candidate))
                    i = input.index(i, offsetBy: 4)
                    continue
                }
                // Special exceptions for Alien names
                if (candidate.endIndex == input.endIndex) {
                    if (candidate == "qirq" || candidate == "rand") {
                        ret.append(String(candidate))
                        i = input.index(i, offsetBy: 4)
                        continue
                    }
                }
                // CVV should not be allowed
                if isVowel(candidate[candidate.index(candidate.startIndex, offsetBy: 2)]) {
                    return [String(input)]
                }
                // We seem to be looking at CVC, advance to the next C which should be the
                // beginning of the next consonant
                ret.append(String(candidate[..<candidate.index(before: candidate.endIndex)]))
                i = input.index(i, offsetBy: 3)
                continue
            }
            // Handle three-character candidates at the end of a word
            if candidate.count == 3 {
                // CVV should not be allowed
                if isVowel(candidate[candidate.index(before: candidate.endIndex)]) {
                    return [String(input)]
                }
                ret.append(String(candidate[..<candidate.endIndex]))
                i = input.index(i, offsetBy: 3)
                continue
            }
            return [String(input)]
        }

        return ret
    }
}
