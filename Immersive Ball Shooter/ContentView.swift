//
//  ContentView.swift
//  Immersive Ball Shooter
//
//  Created by Henry Lam on 29/2/2024.
//
import SwiftUI

struct ContentView: View {
    // MARK: - State Properties
    
    @State private var timeRemaining = 30
    @State private var timeCache = 30
    @State private var readyTime = 3
    @State private var gameStart = false
    @State private var loseGame = false
    @State private var winGame = false
    
    // Timer to update countdown
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // State to manage immersive space visibility
    @State private var showImmersiveSpace = false
    
    // Environment object to access shagreen data
    @EnvironmentObject var counter: CounterModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack {
                // Display appropriate views based on game state
                if loseGame {
                    gameOverView()
                } else if winGame {
                    winGameView()
                } else {
                    if !gameStart {
                        gameSetupView()
                    } else if !showImmersiveSpace {
                        countdownView()
                    }
                    if gameStart && showImmersiveSpace {
                        gamePlayingView()
                    }
                }
            }
        }
        .frame(width: 1100, height: 500)
        .onChange(of: showImmersiveSpace) { _, newValue in
            // Handle changes in immersive space visibility
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
    }

    // MARK: - Game Views
    
    private func gameOverView() -> some View {
        // View displayed when the game is lost
        VStack {
            Text("You Lost!")
                .font(.system(size: 45))
                .fontWeight(.bold)
            Spacer(minLength: 20)
            Text("You shot \(counter.ballCounter)/\(counter.ballMax) green balls in \(timeCache)s.")
                .font(.system(size: 64))
                .fontWeight(.bold)
            Spacer(minLength: 20)
            Button("Try Again!") {
                resetGame()
            }
            .toggleStyle(.button)
            .font(.system(size: 30))
            .fontWeight(.bold)
            .frame(width: 360, height: 120)
        }
    }
    
    private func winGameView() -> some View {
        // View displayed when the game is won
        VStack {
            Text("You Win!")
                .font(.system(size: 45))
                .fontWeight(.bold)
            Spacer(minLength: 20)
            Text("Congratulations!")
                .font(.system(size: 64))
                .fontWeight(.bold)
             Text("You shot all \(counter.ballCounter) green balls in \(timeCache - timeRemaining)s!")
                .font(.system(size: 64))
                .fontWeight(.bold)
            Spacer(minLength: 20)
            Button("Play Again!") {
                resetGame()
            }
            .toggleStyle(.button)
            .font(.system(size: 30))
            .fontWeight(.bold)
            .frame(width: 360, height: 120)
        }
    }
    
    private func gameSetupView() -> some View {
        // View for setting up the game
        VStack {
            Text("Shoot \(counter.ballMax) green balls in \(timeCache)s!")
                .font(.system(size: 54))
                .fontWeight(.bold)
            settingsView(title: "Time Setting", buttons: timeSettingButtons())
            settingsView(title: "Green Ball Setting", buttons: greenBallSettingButtons())
            Spacer(minLength: 20)
            startGameButton()
        }
    }
    
    private func settingsView(title: String, buttons: some View) -> some View {
        // View for displaying settings
        VStack {
            Text(title)
                .font(.system(size: 28))
                .padding(.top, 20)
                .padding(.bottom, 10)
            buttons
        }
    }

    private func timeSettingButtons() -> some View {
        // Buttons for setting time
        HStack {
            Button("15s") { timeCache = 15 }
            Button("30s") { timeCache = 30 }
            Button("60s") { timeCache = 60 }
        }
    }

    private func greenBallSettingButtons() -> some View {
        // Buttons for setting green ball count
        HStack {
            Button("10") { counter.ballMax = 10 }
            Button("25") { counter.ballMax = 25 }
            Button("50") { counter.ballMax = 50 }
        }
    }

    private func startGameButton() -> some View {
        // Button to start the game
        Button("Play") {
            gameStart = true
            timeRemaining = timeCache
        }
        .toggleStyle(.button)
        .font(.system(size: 30))
        .fontWeight(.bold)
        .frame(width: 360, height: 120)
    }

    private func countdownView() -> some View {
        // View for the countdown before the game starts
        Text("\(readyTime)")
            .font(.system(size: 160))
            .fontWeight(.bold)
            .onReceive(timer) { _ in
                if readyTime > 1 {
                    readyTime -= 1
                } else {
                    showImmersiveSpace = true
                    timer.upstream.connect().cancel()
                }
            }
    }

    private func gamePlayingView() -> some View {
        // View for playing the game
        VStack {
            Text("\(timeRemaining)")
                .font(.system(size: 142))
                .fontWeight(.bold)
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        gameEnd()
                    }
                }
            Text("\(counter.ballCounter)/\(counter.ballMax) green balls shot!!")
                .font(.system(size: 52))
                .fontWeight(.semibold)
            Button("Stop") { gameEnd() }
                .toggleStyle(.button)
                .font(.system(size: 30))
                .fontWeight(.bold)
                .frame(width: 360, height: 120)
        }
        .onReceive(timer) { _ in
            if counter.ballCounter == counter.ballMax {
                gameWin()
            }
        }
    }
    
    // MARK: - Game Logic

    private func resetGame() {
        // Reset game parameters
        loseGame = false
        winGame = false
        readyTime = 3
        counter.ballCounter = 0
        gameStart = false
        timeRemaining = timeCache
    }

    private func gameWin() {
        // Handle game win scenario
        gameStart = false
        showImmersiveSpace = false
        winGame = true
        timer.upstream.connect().cancel()
    }
    
    private func gameEnd() {
        // Handle game end scenario
        gameStart = false
        showImmersiveSpace = false
        loseGame = true
        timer.upstream.connect().cancel()
    }

    private func toggleImmersiveSpace() {
        // Toggle immersive space visibility
        Task {
            if showImmersiveSpace {
                await openImmersiveSpace(id: "ImmersiveSpace")
            } else {
                await dismissImmersiveSpace()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
