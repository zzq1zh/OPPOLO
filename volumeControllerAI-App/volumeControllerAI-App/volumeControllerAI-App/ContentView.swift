//
//  ContentView.swift
//  volumeControllerAI-App
//
//  Created by Ziqi Zhang on 9/17/22.
//

import SwiftUI
import Foundation
import MediaPlayer

extension MPVolumeView {
    static func setVolume(_ volume: Float) -> Void {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}


struct TaskEntry: Codable, Identifiable {
    let id = UUID()
    let volume: Float
    
}

struct CardView: View {
    @ObservedObject var volObserver : VolumeObserver

    @State var results = TaskEntry(volume: 0)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func getData() {
        guard let url = URL(string: "http://192.168.1.152:5000/getVolume") else {
            print("Your API end point is Invalid")
            return
        }
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode(TaskEntry.self, from: data) {
                    DispatchQueue.main.async {
                        self.results = response
                        MPVolumeView.setVolume(0.5 + results.volume/100)
                    }
                    return
                }
            }
        }.resume()
    }
    
    var body: some View {
            VStack {
                Text("ADROPPOIT")
                    .font(.headline)
                    .foregroundColor(.secondary)
                VStack {
                    Text("Your Fatigue level")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    ProgressView(value: results.volume / 100).padding()
                }.padding()
                VStack {
                    Text("Current Audio Volume")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    ProgressView(value: 0.5 + results.volume/100).padding()
                }
                .padding()
            }
            .onReceive(timer) { time in
                getData()
            }
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
            )
            .padding([.top, .horizontal])
        }
    }

struct ContentView: View {
    @ObservedObject var volObserver : VolumeObserver = VolumeObserver()

    
    var body: some View {
        CardView(volObserver: volObserver)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
