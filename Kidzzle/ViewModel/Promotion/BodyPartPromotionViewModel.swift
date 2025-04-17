//
//  BodyPartPromotionViewModel.swift
//  Kidzzle
//
//  Created by aynnipa on 13/3/2568 BE.
//

import Foundation
import AVFoundation
import SwiftUI

class BodyPartPromotionViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    // MARK: - Properties
    @Published var bodyParts: [PromotionBodyPart] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentlyPlayingID: String?

    private var audioPlayer: AVAudioPlayer?
    private let audioEngine = AVAudioEngine()
    
    override init() {
        super.init()
        Task {
            await fetchPromotionBodyParts()
        }
    }
    
    // MARK: - Fetch Body Parts
    @MainActor
    func fetchPromotionBodyParts() async {
        isLoading = true
        errorMessage = nil
        
        let urlString = "https://kidzzle-api-807625438905.asia-southeast1.run.app/api/v1/promotions/body-part"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            bodyParts = try decoder.decode([PromotionBodyPart].self, from: data)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Image Handling
    func getFormattedImageURL(for bodyPart: PromotionBodyPart) -> URL? {
        guard var urlString = bodyPart.imageURL?.absoluteString else {
            return nil
        }
        
        // Ensure the URL includes the .png extension
        if let range = urlString.range(of: ".png") {
            urlString = String(urlString[..<range.upperBound])
        }
        
        return URL(string: urlString)
    }
    
    // Preload images with weak reference to avoid retain cycle
    func preloadImages() {
        for bodyPart in bodyParts {
            guard let imageURL = getFormattedImageURL(for: bodyPart) else { continue }
            
            let task = URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
                guard self != nil else { return }
                
                if let error = error {
                    print("Failed to preload image: \(error.localizedDescription)")
                    return
                }
                
                if let data = data, let _ = UIImage(data: data) {
                    DispatchQueue.main.async {
                        print("Successfully preloaded image for body part: \(bodyPart.id)")
                    }
                }
            }
            task.resume()
        }
    }
    
    // Validate image URL with weak self to prevent retain cycle
    func validateImageURL(for bodyPart: PromotionBodyPart, completion: @escaping (Bool) -> Void) {
        guard let imageURL = getFormattedImageURL(for: bodyPart) else {
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
            guard self != nil else {
                completion(false)
                return
            }
            
            guard error == nil else {
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode),
               let data = data,
               let _ = UIImage(data: data) {
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    // MARK: - Audio Handling
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Audio Playback
    func playPromotionBodyPartAudio(for bodyPart: PromotionBodyPart) {
        // หยุดเสียงที่กำลังเล่นอยู่ก่อน (ถ้ามี)
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            currentlyPlayingID = nil
        }
        
        guard let originalURL = bodyPart.audioURL else {
            print("Audio URL is nil")
            return
        }
        
        // ลบ tab characters ออกจาก URL และแก้ไขการ encode ซ้ำซ้อน
        var urlString = originalURL.absoluteString
        
        // แก้ไขปัญหา double encoding ของอักขระภาษาไทย (%25E0 -> %E0)
        urlString = urlString.replacingOccurrences(of: "%25", with: "%")
        
        // ตัดส่วนที่ไม่จำเป็นหลัง .mp3
        if let range = urlString.range(of: ".mp3") {
            urlString = String(urlString[..<range.upperBound])
        }
        
        print("Original URL: \(originalURL)")
        print("Fixed URL string: \(urlString)")
        
        guard let fixedURL = URL(string: urlString) else {
            print("Invalid fixed URL")
            return
        }
        
        // ล้าง player เดิม
        if let player = audioPlayer {
            player.pause()
            audioPlayer = nil
        }
        
        // ทำให้ audio session เตรียมพร้อมสำหรับการเล่นเสียง
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("ไม่สามารถตั้งค่า audio session: \(error.localizedDescription)")
            return
        }
        
        // สร้าง URL request ที่มาพร้อมกับ cache policy
        var request = URLRequest(url: fixedURL)
        request.cachePolicy = .returnCacheDataElseLoad
        
        // ใช้ URLSession เพื่อดาวน์โหลดไฟล์เสียงจาก URL
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.currentlyPlayingID = nil
                }
                print("ไม่สามารถดาวน์โหลดไฟล์เสียงได้: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                // เล่นเสียงจากข้อมูลที่ดาวน์โหลดมา
                self.audioPlayer = try AVAudioPlayer(data: data)
                self.audioPlayer?.delegate = self
                
                // ตรวจสอบว่าสร้าง player สำเร็จหรือไม่
                if self.audioPlayer == nil {
                    print("ไม่สามารถสร้าง audio player ได้")
                    DispatchQueue.main.async {
                        self.currentlyPlayingID = nil
                    }
                    return
                }
                
                // เริ่มเล่นเสียง
                let success = self.audioPlayer?.play() ?? false
                
                DispatchQueue.main.async {
                    if success {
                        self.currentlyPlayingID = bodyPart.id
                    } else {
                        self.currentlyPlayingID = nil
                        print("ไม่สามารถเริ่มเล่นเสียงได้")
                    }
                }
            } catch {
                print("ไม่สามารถเล่นเสียงได้: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.currentlyPlayingID = nil
                }
            }
        }
        
        task.resume()
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        currentlyPlayingID = nil
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.currentlyPlayingID = nil
        }
    }
}
