//
//  OptionsView.swift
//  Trivia Game
//
//  Created by Samir Acharya on 03/07/26.
//

import SwiftUI

struct OptionsView: View {
    @Environment(TriviaManager.self) var triviaManager
    
    @State private var numberOfQuestions: String = "5"
    @State private var selectedCategory: TriviaCategory = .sports
    @State private var difficultySliderValue: Double = 0
    @State private var selectedType: TriviaType = .multiple
    @State private var selectedTimer: TimerDuration = .sixty
    @State private var navigateToTrivia = false
    
    private var selectedDifficulty: TriviaDifficulty {
        switch Int(difficultySliderValue) {
        case 0: return .easy
        case 1: return .medium
        default: return .hard
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // App title banner with gradient
            ZStack {
                LinearGradient(
                    colors: [Color.indigo, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .ignoresSafeArea(edges: .top)
                
                HStack(spacing: 10) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 30))
                    Text("Trivia Game")
                        .font(.system(size: 34, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.bottom, 16)
            }
            .frame(height: 100)
            
            // Settings form for quiz configuration
            Form {
                // How many questions to fetch
                Section {
                    TextField("Number of Questions", text: $numberOfQuestions)
                        .keyboardType(.numberPad)
                }
                
                // Topic picker
                Section {
                    Picker("Select Category", selection: $selectedCategory) {
                        ForEach(TriviaCategory.allCases) { category in
                            Text(category.name).tag(category)
                        }
                    }
                }
                
                // Difficulty slider (easy → hard)
                Section {
                    VStack(alignment: .leading) {
                        Text("Difficulty: \(selectedDifficulty.displayName)")
                        Slider(value: $difficultySliderValue, in: 0...2, step: 1)
                            .tint(.indigo)
                    }
                }
                
                // Multiple choice vs true/false
                Section {
                    Picker("Select Type", selection: $selectedType) {
                        ForEach(TriviaType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }
                
                // Countdown length
                Section {
                    Picker("Timer Duration", selection: $selectedTimer) {
                        ForEach(TimerDuration.allCases) { duration in
                            Text(duration.displayName).tag(duration)
                        }
                    }
                }
            }
            
            // Kick off the quiz
            Button(action: {
                let amount = Int(numberOfQuestions) ?? 5
                Task {
                    await triviaManager.fetchTrivia(
                        amount: amount,
                        category: selectedCategory,
                        difficulty: selectedDifficulty,
                        type: selectedType,
                        timerDuration: selectedTimer
                    )
                    navigateToTrivia = true
                }
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Trivia")
                }
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.indigo, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .background(Color(.systemGray6))
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToTrivia) {
            TriviaView()
        }
    }
}

#Preview {
    NavigationStack {
        OptionsView()
            .environment(TriviaManager())
    }
}
