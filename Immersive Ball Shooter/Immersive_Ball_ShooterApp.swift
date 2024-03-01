//
//  Immersive_Ball_ShooterApp.swift
//  Immersive Ball Shooter
//
//  Created by Henry Lam on 29/2/2024.
//
import SwiftUI

@main
struct Immersive_Ball_ShooterApp: App {
    @StateObject var counter = CounterModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(counter)
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environmentObject(counter)
        }
    }
}
