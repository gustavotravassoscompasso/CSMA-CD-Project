//
//  SwiftUIView.swift
//  CSMA-CD-Project
//
//  Created by Gustavo Igor Goncalves Travassos on 19/06/23.
//

import SwiftUI

struct Program: View {
    @StateObject var environment = Environment()
    
    var body: some View {
        VStack {
            Button {
                self.environment.stopSimulation()
            } label: {
                Text("Pause Simulation")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .background(.pink)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        
        .onAppear() {
            self.environment.prepareSimulation()
        }
        
        .onReceive(self.environment.globalClock) { _ in
            self.environment.executeSimulationLoop()
        }
    }
}
