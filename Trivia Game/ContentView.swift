//
//  ContentView.swift
//  Trivia Game
//
//  Created by Samir Acharya on 03/07/26.
//

import SwiftUI

struct ContentView: View {
    @State private var triviaManager = TriviaManager()
    
    var body: some View {
        NavigationStack {
            OptionsView()
        }
        .environment(triviaManager)
    }
}

#Preview {
    ContentView()
}
