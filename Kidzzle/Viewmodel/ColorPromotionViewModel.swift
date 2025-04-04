//
//  ColorPromotionViewModel.swift
//  Kidzzle
//
//  Created by aynnipa on 12/3/2568 BE.
//

import SwiftUI
import AVFoundation
import Speech

class ColorPromotionViewModel: NSObject, ObservableObject {
    @Published var colors: [PromotionColor] = []
    @Published var currentlyPlayingID: String?
    @Published var transcribedText: String = ""
    @Published var isRecording: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSpeechCorrect: Bool = false
    @Published var currentColorIndex: Int = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "th-TH"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override init() {
        super.init()
        requestSpeechAuthorization()
        fetchPromotionColors()
    }
    
    func fetchPromotionColors() {
        guard let url = URL(string: "https://kidzzle-api-kidzzle-807625438905.asia-southeast1.run.app/api/v1/promotions/color") else {
            errorMessage = "URL ไม่ถูกต้อง"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "เกิดข้อผิดพลาดในการเชื่อมต่อ: \(error.localizedDescription)"
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "เกิดข้อผิดพลาดจากเซิร์ฟเวอร์"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "ไม่พบข้อมูล"
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedShapes = try decoder.decode([PromotionColor].self, from: data)
                
                DispatchQueue.main.async {
                    self?.colors = decodedShapes
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "เกิดข้อผิดพลาดในการถอดรหัสข้อมูล: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func retry() {
        fetchPromotionColors()
    }
    
    // MARK: - Image Handling
    func getFormattedImageURL(for color: PromotionColor) -> URL? {
        
        guard let originalURL = color.imageURL else {
            print("Image URL is nil")
            return nil
        }
        
        var urlString = originalURL.absoluteString
        urlString = urlString.replacingOccurrences(of: "\t", with: "")

        if let range = urlString.range(of: ".png") {
            urlString = String(urlString[..<range.upperBound])
        }
        
        return URL(string: urlString)
    }
    
    // Preload images with weak reference to avoid retain cycle
    func preloadImages() {
        for color in colors {
            guard let imageURL = getFormattedImageURL(for: color) else { continue }
            
            let task = URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
                guard self != nil else { return }
                
                if let error = error {
                    print("Failed to preload image: \(error.localizedDescription)")
                    return
                }
                
                if let data = data, let _ = UIImage(data: data) {
                    DispatchQueue.main.async {
                        print("Successfully preloaded image for color: \(color.id)")
                    }
                }
            }
            task.resume()
        }
    }
    
    func validateImageURL(for color: PromotionColor, completion: @escaping (Bool) -> Void) {
        guard let imageURL = getFormattedImageURL(for: color) else {
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
            // ตรวจสอบ self และใช้งานอย่างมีความหมาย
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
    
    // MARK: - Audio Playback
    func playPromotionColorAudio(for color: PromotionColor) {
        // หยุดเสียงที่กำลังเล่นอยู่ก่อน (ถ้ามี)
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            currentlyPlayingID = nil
        }
        
        guard let originalURL = color.audioURL else {
            print("Audio URL is nil")
            return
        }
        
        // ลบ tab characters ออกจาก URL และแก้ไขการ encode ซ้ำซ้อน
        var urlString = originalURL.absoluteString
        urlString = urlString.replacingOccurrences(of: "\t", with: "")
        urlString = urlString.replacingOccurrences(of: "%09", with: "")
        
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
                        self.currentlyPlayingID = color.id
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
    
    // MARK: - Speech Recognition
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("การเข้าถึงการรู้จำเสียงพูดได้รับอนุญาตแล้ว")
                case .denied, .restricted, .notDetermined:
                    print("ไม่ได้รับอนุญาตให้เข้าถึงการรู้จำเสียงพูด")
                @unknown default:
                    print("สถานะไม่รู้จัก")
                }
            }
        }
    }
    
    func startSpeechRecognition() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // หยุดเล่นเสียงที่กำลังเล่นอยู่ก่อน
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            currentlyPlayingID = nil
        }
        
        // รีเซ็ตค่าความถูกต้อง
        isSpeechCorrect = false
        
        // ตั้งค่า audio session สำหรับการบันทึกเสียง
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("ไม่สามารถตั้งค่า audio session สำหรับการบันทึกเสียงได้: \(error)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest, speechRecognizer?.isAvailable == true else {
            print("ไม่สามารถสร้างคำขอการรู้จำเสียงพูดได้ หรือ speech recognizer ไม่พร้อมใช้งาน")
            isRecording = false
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
                isFinal = result.isFinal
                
                // ตรวจสอบความถูกต้องของคำพูดถ้ามีสีปัจจุบัน
                if !self.colors.isEmpty && self.currentColorIndex < self.colors.count {
                    self.isSpeechCorrect = self.checkSpeechCorrectness(for: self.colors[self.currentColorIndex])
                    
                    // หยุดบันทึกเสียงอัตโนมัติถ้าพูดถูกต้อง
                    if self.isSpeechCorrect || (!self.transcribedText.isEmpty && isFinal) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if self.isRecording {
                                self.stopSpeechRecognitionInternal()
                            }
                        }
                    }
                }
            }
            
            if error != nil || isFinal {
                self.stopSpeechRecognitionInternal()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            print("ไม่สามารถเริ่มเครื่องยนต์เสียงได้: \(error.localizedDescription)")
            stopSpeechRecognitionInternal()
        }
    }
    
    private func stopSpeechRecognitionInternal() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
    
    func stopSpeechRecognition() {
        stopSpeechRecognitionInternal()
    }
    
    func checkSpeechCorrectness(for color: PromotionColor) -> Bool {
        guard !transcribedText.isEmpty else { return false }
        
        // ตัดช่องว่างทั้งสองข้างและแปลงเป็นตัวพิมพ์เล็ก
        let colorName = color.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let userSpeech = transcribedText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // แยกส่วนภาษาไทยออกจากชื่อสี (สมมติว่าส่วนภาษาอังกฤษอยู่ในวงเล็บ)
        var thaiColorName = colorName
        if let bracketRange = colorName.range(of: "(") {
            thaiColorName = String(colorName[..<bracketRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // แยกคำเพื่อค้นหาสีที่แน่ชัด
        let colorWords = thaiColorName.components(separatedBy: .whitespacesAndNewlines)
        
        // ฟังก์ชันกรองข้อความเพื่อให้เหลือแต่คำที่เกี่ยวข้องกับสี
        func extractColorWords(_ text: String) -> [String] {
            let words = text.components(separatedBy: .whitespacesAndNewlines)
            return words.filter { colorWords.contains($0) }
        }
        
        let relevantColorWordsInSpeech = extractColorWords(userSpeech)
        
        // ตรวจสอบการตรงกันของคำสี
        let hasExactColorWords = !relevantColorWordsInSpeech.isEmpty
        
        if !hasExactColorWords {
            stopSpeechRecognition()
        }
        
        return hasExactColorWords
    }
    
    func moveToNextColor() {
        if currentColorIndex < colors.count - 1 {
            currentColorIndex += 1
        } else {
            currentColorIndex = 0
        }
        
        // รีเซ็ตค่าต่างๆ
        transcribedText = ""
        isSpeechCorrect = false
    }
 }


 // MARK: - Audio Player Delegate
 extension ColorPromotionViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.currentlyPlayingID = nil
        }
    }
 }
