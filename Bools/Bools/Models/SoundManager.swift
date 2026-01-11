//
//  SoundManager.swift
//  Bools 2.0
//
//  Manager for playing UI sounds
//

import Foundation
import AVFoundation
import Combine
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import AudioToolbox
#endif

class SoundManager: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var buzzerPlayers: [UUID: AVAudioPlayer] = [:]
    private var buzzerSounds: [UUID: NSSound] = [:]
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        #if os(macOS)
        // macOS doesn't require audio session configuration
        #else
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        #endif
    }
    
    func playBuzzerSound(_ soundType: String, for buzzerID: UUID) {
        #if os(macOS)
        // Останавливаем предыдущий звук для этого зуммера, если играет
        if let existingSound = buzzerSounds[buzzerID] {
            existingSound.stop()
        }
        
        // На macOS используем короткий системный звук (не зацикленный)
        switch soundType {
        case "beep":
            if let sound = NSSound(named: "Tink") {
                sound.play()
            }
        case "alarm":
            if let sound = NSSound(named: "Basso") {
                sound.play()
            }
        case "tone":
            if let sound = NSSound(named: "Funk") {
                sound.play()
            }
        default:
            if let sound = NSSound(named: "Tink") {
                sound.play()
            }
        }
        #else
        // На iOS используем системные звуки
        switch soundType {
        case "beep":
            AudioServicesPlaySystemSound(1057) // Beep
        case "alarm":
            AudioServicesPlaySystemSound(1005) // Alert
        case "tone":
            AudioServicesPlaySystemSound(1057)
        default:
            AudioServicesPlaySystemSound(1057)
        }
        #endif
    }
    
    func stopBuzzerSound(for buzzerID: UUID) {
        #if os(macOS)
        if let sound = buzzerSounds[buzzerID] {
            sound.stop()
            buzzerSounds.removeValue(forKey: buzzerID)
        }
        #endif
        
        if let player = buzzerPlayers[buzzerID] {
            player.stop()
            buzzerPlayers.removeValue(forKey: buzzerID)
        }
    }
    
    func stopAllBuzzerSounds() {
        #if os(macOS)
        for (_, sound) in buzzerSounds {
            sound.stop()
        }
        buzzerSounds.removeAll()
        #endif
        
        for (_, player) in buzzerPlayers {
            player.stop()
        }
        buzzerPlayers.removeAll()
    }
    
    func playSound(named soundName: String, volume: Float = 0.5) {
        // Проверяем, есть ли уже загруженный плеер для этого звука
        if let player = audioPlayers[soundName] {
            player.currentTime = 0
            player.volume = volume
            player.play()
            return
        }
        
        // Пытаемся загрузить звук из ресурсов
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "aiff") ??
                         Bundle.main.url(forResource: soundName, withExtension: "wav") ??
                         Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Sound file not found: \(soundName)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            audioPlayers[soundName] = player
            player.play()
        } catch {
            print("Failed to play sound \(soundName): \(error)")
        }
    }
    
    func preloadSound(named soundName: String) {
        guard audioPlayers[soundName] == nil else { return }
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "aiff") ??
                         Bundle.main.url(forResource: soundName, withExtension: "wav") ??
                         Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayers[soundName] = player
        } catch {
            print("Failed to preload sound \(soundName): \(error)")
        }
    }
}
