//
//  ColorPromotionView.swift
//  Kidzzle
//
//  Created by aynnipa on 12/3/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct ColorPromotionView: View {
    @StateObject private var viewModel = ColorPromotionViewModel()
    @Binding var isPresented: Bool
    @State private var speechText: String = ""
    @State private var timer: Timer? = nil
    
    @State var progress: CGFloat = 0
    
    private let minHeight = 100.0
    private let maxHeight = 180.0
    
    var body: some View {
        ZStack {
            ScalingHeaderScrollView {
                largeHeader(progress: progress)
            } content: {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 20)
                    
                    if let currentColor = currentColor {
                        ColorPromotionCard(
                            colors: currentColor,
                            viewModel: viewModel,
                            speechText: $speechText,
                            progressScoreText: progressScoreText
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .height(min: minHeight, max: maxHeight)
            .collapseProgress($progress)
            .allowsHeaderGrowth()
            .background(Color.ivorywhite)
            
            smallHeader
        }
        .ignoresSafeArea()
        .task {
            viewModel.fetchPromotionColors()
            viewModel.preloadImages()
        }
    }
    
    private var smallHeader: some View {
        VStack {
            HStack(spacing: 16) {
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.jetblack)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .cornerRadius(10)
                })
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                if progress >= 0.99 {
                    Text("สีแสนสนุก")
                        .font(customFont(type: .bold, textStyle: .headline))
                        .foregroundColor(.jetblack)
                        .transition(
                            .opacity
                                .combined(with: .offset(y: -8))
                        )
                        .animation(.easeInOut(duration: 0.12), value: progress)
                }
                
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.top, 48)
            
            Spacer()
        }
        .ignoresSafeArea()
    }
    
    private func largeHeader(progress: CGFloat) -> some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("สีแสนสนุก")
                        .font(customFont(type: .bold, textStyle: .title2))
                        .foregroundColor(.jetblack)
                    
                    Text("เรียนรู้และฝึกออกเสียงชื่อสี เพื่อส่งเสริมทักษะด้านการเข้าใจภาษา (RL) และการใช้ภาษา (EL)")
                        .font(customFont(type: .regular, textStyle: .footnote))
                        .foregroundColor(.jetblack)
                        .lineLimit(2, reservesSpace: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 104)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(progress >= 1.0 ? 0 : 1)
                .offset(y: progress >= 1.0 ? -5 : 0)
                .animation(.easeOut(duration: 0.15), value: progress)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .background(Color.ivorywhite)
    }
    
    private var progressScoreText: String {
        return "\(viewModel.currentColorIndex + 1)/\(viewModel.colors.count)"
    }
    
    private var currentColor: PromotionColor? {
        if viewModel.colors.isEmpty || viewModel.currentColorIndex >= viewModel.colors.count { return nil }
        return viewModel.colors[viewModel.currentColorIndex]
    }
}

struct ColorPromotionCard: View {
    let colors: PromotionColor
    @ObservedObject var viewModel: ColorPromotionViewModel
    @Binding var speechText: String
    let progressScoreText: String
    @State private var isImageFlipped = false
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            Text(progressScoreText)
                .font(customFont(type: .medium, textStyle: .caption1))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 20)
                .padding(.horizontal, 20)

            VStack {
                if let imageURL = viewModel.getFormattedImageURL(for: colors) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 200, height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                                .rotation3DEffect(
                                    Angle(degrees: isImageFlipped ? 180 : 0),
                                    axis: (x: 0.0, y: 1.0, z: 0.0)
                                )
                                .animation(.spring(response: 0.5), value: isImageFlipped)
                                .overlay(
                                    Image(systemName: "arrow.left.and.right.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                        .opacity(0.7)
                                        .padding(8),
                                    alignment: .bottomTrailing
                                )
                        case .failure:
                            VStack {
                                Image(systemName: "photo.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("ไม่สามารถโหลดรูปภาพได้")
                                    .font(customFont(type: .regular, textStyle: .caption1))
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 200, height: 200)
                        @unknown default:
                            EmptyView()
                                .frame(width: 200, height: 200)
                        }
                    }
                    .frame(width: 200, height: 200)
                    .padding(.vertical, 20)
                    .onTapGesture {
                        isImageFlipped.toggle()
                    }
                }
                
                HStack(alignment: .center, spacing: 8) {
                    Text("\(colors.name)")
                        .font(customFont(type: .bold, textStyle: .title2))
                    
                    Button(action: {
                        viewModel.playPromotionColorAudio(for: colors)
                    }) {
                        Image(systemName: viewModel.currentlyPlayingID != nil ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(viewModel.currentlyPlayingID != nil ? .coralRed : .deepBlue)
                    }
                    .disabled(viewModel.isRecording)
                    .opacity(viewModel.isRecording ? 0.5 : 1)
                    .padding(.horizontal, 8)
                }
                
                Text("รูปทรง : \(colors.shape)")
                    .font(customFont(type: .regular, textStyle: .callout))
                    .padding(.top, 8)
                
                Text("สีของรูปทรง : \(colors.name)")
                    .font(customFont(type: .regular, textStyle: .callout))
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("แปลงเสียงเป็นข้อความ :")
                            .font(customFont(type: .bold, textStyle: .body))
                        
                        Spacer()
                        
                        if !speechText.isEmpty {
                            if viewModel.isSpeechCorrect {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("ถูกต้อง")
                                }
                                .foregroundColor(.greenMint)
                                .font(customFont(type: .bold, textStyle: .subheadline))
                            } else {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("ไม่ถูกต้อง")
                                }
                                .foregroundColor(.coralRed)
                                .font(customFont(type: .bold, textStyle: .subheadline))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    ZStack(alignment: .trailing) {
                        Text(speechText.isEmpty ? "ข้อความ..." : speechText)
                            .font(customFont(type: .regular, textStyle: .body))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.isRecording ? Color.deepBlue :
                                            (viewModel.isSpeechCorrect ? Color.greenMint :
                                             (!speechText.isEmpty ? Color.coralRed : Color.gray)),
                                            lineWidth: viewModel.isRecording ? 2 : 1)
                            )
                            .foregroundColor(speechText.isEmpty ? Color.gray.opacity(0.5) : .jetblack)
                        
                        if !speechText.isEmpty && !viewModel.isRecording {
                            Button(action: {
                                speechText = ""
                                viewModel.transcribedText = ""
                            }) {
                                Image(systemName: "xmark.bin.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.coralRed)
                                    .padding(6)
                            }
                            .padding(.trailing, 6)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
                
                VStack(spacing: 12) {
                    Button(action: {
                        if !viewModel.isRecording {
                            speechText = ""
                            viewModel.startSpeechRecognition()
                        } else {
                            viewModel.stopSpeechRecognition()
                        }
                    }) {
                        HStack {
                            Image(systemName: viewModel.isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                                .font(.system(size: 20))
                            Text(viewModel.isRecording ? "หยุดพูด" : "เริ่มพูด")
                                .font(customFont(type: .bold, textStyle: .body))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.isRecording ? Color.coralRed : Color.black)
                        .cornerRadius(10)
                    }
                    .disabled(viewModel.isRecording == false && !speechText.isEmpty)
                    .opacity(viewModel.isRecording == false && !speechText.isEmpty ? 0.5 : 1)
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        viewModel.moveToNextColor()
                        speechText = ""
                        viewModel.transcribedText = ""
                    }) {
                        Text("ถัดไป")
                            .font(customFont(type: .bold, textStyle: .body))
                    }
                    .foregroundColor(viewModel.isSpeechCorrect ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(viewModel.isSpeechCorrect ? .greenMint : .gray)
                    .cornerRadius(10)
                    .disabled(!viewModel.isSpeechCorrect)
                    .opacity(viewModel.isSpeechCorrect ? 1.0 : 0.5)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
        .onReceive(viewModel.$transcribedText) { newValue in
            if speechText != newValue {
                speechText = newValue
            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if speechText != viewModel.transcribedText {
                    speechText = viewModel.transcribedText
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

#Preview {
    ColorPromotionView(isPresented: .constant(false))
}
