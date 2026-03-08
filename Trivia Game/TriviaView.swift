//
//  TriviaView.swift
//  Trivia Game
//
//  Created by Samir Acharya on 03/07/26.
//

import SwiftUI

struct TriviaView: View {
    @Environment(TriviaManager.self) var triviaManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        @Bindable var bindableTriviaManager = triviaManager
        VStack(spacing: 0) {
            // Countdown bar at the top
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.title2)
                Text("Time remaining: \(triviaManager.timeRemaining)s")
                    .font(.system(size: 24, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.indigo, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            if triviaManager.isLoading {
                Spacer()
                ProgressView("Loading questions...")
                    .font(.title3)
                Spacer()
            } else if let error = triviaManager.errorMessage {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Spacer()
            } else {
                // Scrollable list of question cards
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(Array(triviaManager.questions.enumerated()), id: \.element.id) { index, question in
                            QuestionCardView(
                                questionIndex: index,
                                question: question,
                                answers: triviaManager.shuffledAnswers.indices.contains(index) ? triviaManager.shuffledAnswers[index] : []
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(Color(.systemGray6).opacity(0.5))
                
                // Finalize answers
                Button(action: {
                    triviaManager.submitAnswers()
                }) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Submit")
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
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    triviaManager.stopTimer()
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.indigo)
                }
            }
        }
        .alert("Score", isPresented: $bindableTriviaManager.showScore) {
            Button("OK") { }
        } message: {
            Text("You scored \(triviaManager.score) out of \(triviaManager.questions.count)")
        }
    }
}

// MARK: - Individual Question Card

struct QuestionCardView: View {
    @Environment(TriviaManager.self) var triviaManager
    let questionIndex: Int
    let question: TriviaQuestion
    let answers: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Display the question prompt
            Text(question.question)
                .font(.body)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 4)
            
            // Tappable answer choices
            ForEach(Array(answers.enumerated()), id: \.offset) { answerIndex, answer in
                AnswerRowView(
                    label: triviaManager.answerLabel(answerIndex),
                    answer: answer,
                    isSelected: triviaManager.selectedAnswers[questionIndex] == answer,
                    isCorrect: triviaManager.isCorrect(questionIndex: questionIndex, answer: answer),
                    isSubmitted: triviaManager.isSubmitted,
                    wasSelected: triviaManager.selectedAnswers[questionIndex] == answer
                )
                .onTapGesture {
                    triviaManager.selectAnswer(for: questionIndex, answer: answer)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Single Answer Option Row

struct AnswerRowView: View {
    let label: String
    let answer: String
    let isSelected: Bool
    let isCorrect: Bool
    let isSubmitted: Bool
    let wasSelected: Bool
    
    private var backgroundColor: Color {
        if isSubmitted {
            if isCorrect {
                return Color.green.opacity(0.15)
            } else if wasSelected && !isCorrect {
                return Color.red.opacity(0.15)
            }
        }
        if isSelected {
            return Color.indigo.opacity(0.1)
        }
        return Color(.systemGray6)
    }
    
    private var borderColor: Color {
        if isSubmitted {
            if isCorrect {
                return .green
            } else if wasSelected && !isCorrect {
                return .red
            }
        }
        if isSelected {
            return .indigo
        }
        return Color(.systemGray4)
    }
    
    var body: some View {
        HStack {
            Text("\(label). \(answer)")
                .font(.body)
                .fontWeight(isSelected ? .medium : .regular)
            
            Spacer()
            
            if isSelected && !isSubmitted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.indigo)
                    .font(.title3)
            }
            
            if isSubmitted && isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            }
            
            if isSubmitted && wasSelected && !isCorrect {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding(12)
        .background(backgroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: isSelected || (isSubmitted && (isCorrect || wasSelected)) ? 1.5 : 0.5)
        )
    }
}

#Preview {
    NavigationStack {
        TriviaView()
            .environment(TriviaManager())
    }
}
