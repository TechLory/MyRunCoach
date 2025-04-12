//
//  WelcomeScreen.swift
//  MyRunCoach
//
//  Created by Lorenzo Gatta on 30/03/25.
//

import SwiftUI

struct WelcomeScreen: View {
    
    @Binding var isVisible: Bool
    
    var body: some View {
        ZStack {
            background
            VStack {
                TabView {
                    cardBuilder(text: "Set the frame.", icon: "person.crop.artframe")
                    cardBuilder(text: "Time to run!", icon: "figure.run.treadmill")
                    cardBuilder(text: "Get real-time posture corrections.", icon: "airpods.gen3")
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                callToActionSection
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func cardBuilder(text: String, icon: String) -> some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding()
                .foregroundStyle(Color.accentColor)
            
            Text(text)
                .font(.title2)
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal)
            
        }
        .frame(maxWidth: .infinity)
    }
    
    
    private var callToActionSection: some View {
        VStack {
            Text("Improve your posture with MyRunCoach.")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical, 40)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(10)
            
            Text("Start your treadmill session now!")
                .font(.headline)
                .foregroundStyle(.gray)
                .padding(.top, 30)
            
            Button("Get Started") {
                isVisible = false
            }
            .frame(maxWidth: .infinity)
            .font(.title2)
            .fontWeight(.bold)
            .padding()
            .foregroundStyle(.black)
            .background() {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color.accentColor)
            }
            .padding(.top, 30)

            Text("No registration required.")
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.top, 10)
                .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background() {
            RoundedRectangle(cornerRadius: 50)
                .foregroundStyle(.ultraThinMaterial)
                .ignoresSafeArea()
        }
    }
    
    private var background: some View {
        ZStack {
            VStack {
                Circle()
                    .fill(.green)
                    .scaleEffect(0.6)
                    .offset(x: 20)
                    .blur(radius: 120)
                Circle()
                    .fill(.red)
                    .scaleEffect(0.6, anchor: .leading)
                    .offset(x: -20)
                    .blur(radius: 120)
            }
            Rectangle()
                .fill(.ultraThinMaterial)
        }
        .ignoresSafeArea()
    }
}


#Preview {
    ContentView()
}
