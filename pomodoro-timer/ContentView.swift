//
//  ContentView.swift
//  pomodoro-timer
//
//  Created by ryan schofield on 7/19/25.
//

import SwiftUI
import AVFoundation

func getCountdownDisplay(remaining: Int, paused: Bool) -> String {
    if remaining <= 0 {
        return "Done"
    }
    
    let minutes: Int = remaining / 60
    let seconds: Int = remaining % 60

    let minutesDisp = String(minutes)
    
    let secondsDisp = seconds >= 10 ? String(seconds) : "0" + String(seconds)
    
    var disp = "\(minutesDisp):\(secondsDisp)"
    
    if paused { disp += " (paused)" }
        
    return disp
}

let longInterval = 25 * 60
let shortInterval = 5 * 60
let cycleLength = 4
//let longInterval = 12

var audioPlayer: AVAudioPlayer?

enum Status {
    case work
    case relax
}


struct ContentView: View {
    @State var status = Status.work
    @State var timeRemaining = longInterval
    @State var paused = false
    @State var message = "Pomodoro"
    @State var numCompleted = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    
//    let display =

    var body: some View {
        
        VStack {
            Text(message)
                .padding([.top], 30)
                .padding([.bottom], 20)
                .font(.system(size: 24))
            
            Text("completed: " + String(numCompleted))
            
            HStack {
                if timeRemaining > 0 {
                    Button(paused ? "resume" : "pause") {
                        paused = !paused
                    }
                }
                
                if timeRemaining <= 0 {
                    Button("restart") {
                        paused = true
                        if status == Status.work {
                            numCompleted += 1
                            
                            var newInterval = shortInterval
                            if numCompleted % cycleLength == 0 && numCompleted > 0 {
                                 newInterval = longInterval
                            }
                            status = Status.relax
                            timeRemaining = newInterval
                            
                        } else {
                            status = Status.work
                            timeRemaining = longInterval
                        }
                    }
                }
                
            }
            
            
            
            Text(getCountdownDisplay(remaining: timeRemaining, paused: paused))
                .padding([.all], 40)
                .frame(width: 300, height: 300)
                .font(.system(size: 32))
                .onReceive(timer) { _ in
                    if timeRemaining > 0 && !paused {
                        timeRemaining -= 1
                    }
                    
                    if timeRemaining == 0 {
                        playSound(status)
                        timeRemaining -= 1
                    }
                }
        }
        
        
        
    }
}

func playSound(_ status: Status) {
    let uri = status == Status.work ? "chill-chords-143504.mp3" : "trance-loop.mp3"

    
    guard let url = Bundle.main.url(forResource: uri, withExtension: nil) else {
            print("Sound file not found")
            return
        }
    
    
    do {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    } catch {
        print("Error playing sound: \(error.localizedDescription)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
