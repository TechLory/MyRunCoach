//
//  ContentView.swift
//  MyRunCoach
//
//  Created by Lorenzo Gatta on 30/03/25.
//

import SwiftUI

struct ContentView: View {

    var mainScreen = MainScreen()
    
    var body: some View {
        ZStack {
            mainScreen
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
