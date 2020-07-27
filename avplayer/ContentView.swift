//
//  ContentView.swift
//  avplayer
//
//  Created by kangyu on 2020/7/27.
//  Copyright © 2020 kangyu. All rights reserved.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @State var player:AVPlayer?//这里不能用！，否则 self.player?.isPlaying ?? false 会报错
    @State var sliderValue:Double = 0
    @State var loadTimeLabel:String = "00:00:00"
    @State var totalTimeLabel:String = "00:00:00"
    @State var isPlaying = false
    @State var duration:Double = 0.0
    
    func changeTimeFormat(timeInterval:TimeInterval) -> String{
        return String(format: "%02d:%02d:%02d", Int(timeInterval) / 3600, (Int(timeInterval) % 3600) / 60, Int(timeInterval) % 60)
    }

    var body: some View {
        VStack {
            Slider(value: Binding(
                        get: {
                            self.sliderValue
                        },
                        set: {(newValue) in
                            self.sliderValue = newValue
                            self.player?.seek(to: CMTime(seconds: newValue*self.duration, preferredTimescale: 1000))
                        }
                    ))
            .padding(.horizontal,15)
            HStack{
                Text(loadTimeLabel)
                Spacer()
                Text(totalTimeLabel)
            }.padding(.horizontal,15)
            Button(action: {
                if self.isPlaying{
                    self.isPlaying.toggle()
                    self.player?.pause()
                } else {
                    self.isPlaying.toggle()
                    self.player?.play()
                }
            }){
                if self.isPlaying{
                    Image(systemName: "pause")
                    .resizable()
                    .foregroundColor(.blue)
                    .frame(width: 50,height: 50)
                } else {
                    Image(systemName: "play")
                    .resizable()
                    .foregroundColor(.blue)
                    .frame(width: 50,height: 50)
                }
                
            }.padding()
                        
        }.onAppear{
            let audioSession = AVAudioSession.sharedInstance()

            do {
                //.playback :The category for playing recorded music or other sounds that are central to the successful use of your app.
                try audioSession.setCategory(.playback)
                //Specify true to activate your app’s audio session, or false to deactivate it.
                try audioSession.setActive(true)
            } catch let error as NSError {
                print("audioSession error: \(error.localizedDescription)")
            }
            //bundle文件
            let path = Bundle.main.path(forResource: "recoder.wav", ofType:nil)!
            let filePath = URL(fileURLWithPath: path)
            let interval = CMTime(seconds: 0.1,preferredTimescale: CMTimeScale(NSEC_PER_SEC))

            self.player = AVPlayer(url: filePath)
            
            self.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
                //正在播放的时间
                let loadTime = CMTimeGetSeconds(time)

                //总时间
                let totalTime = CMTimeGetSeconds((self.player?.currentItem?.duration)!)
                //播放进度设置
                self.sliderValue = loadTime/totalTime
                //播放的时间（changeTimeFormat方法是转格式的）
                self.loadTimeLabel = self.changeTimeFormat(timeInterval: loadTime)
                //播放完成重置
                if(loadTime == totalTime) {
                    self.loadTimeLabel = "00:00:00"
                    self.isPlaying = false
                    self.player?.seek(to: .zero)
                }
                
            }
            
            self.duration = Double(CMTimeGetSeconds((self.player?.currentItem?.asset.duration)!))
            //总时间Lable
            self.totalTimeLabel = self.changeTimeFormat(timeInterval:CMTimeGetSeconds((self.player?.currentItem?.asset.duration)!))
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

