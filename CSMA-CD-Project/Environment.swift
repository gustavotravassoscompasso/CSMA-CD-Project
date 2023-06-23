//
//  Environment.swift
//  CSMA-CD-Project
//
//  Created by Gustavo Igor Goncalves Travassos on 19/06/23.
//

import SwiftUI
import Combine

let globalClockTime = 1
let numberOfTransmitters = 3
let randomRange = 10

final class Environment: ObservableObject {
    let channel: Channel
    
    var connectedTimer: Cancellable? = nil
    var transmitters: [Transmitter]
    var globalClock = Timer.publish(every: TimeInterval(globalClockTime), on: .main, in: .common).autoconnect()
    
    
    init() {
        self.transmitters = []
        self.channel = Channel()
    }
    
    func prepareSimulation() {
        print("[Environment] - Preparando simulação")
        
        createTransmitters()
        
        print("[Environment] - Simulação pronta\n")
    }
    
    func executeSimulationLoop() {
        print("-------------------------------------")
        runTransmitters()
        channel.verifyCrashs()
        print("-------------------------------------")
    }
    
    func stopSimulation() {
        cancelGlobalClock()
    }
    
    func createTransmitters() {
        for index in 0..<numberOfTransmitters {
            let sensingTime = Int.random(in: 1...randomRange)
            let transmitter = Transmitter(id: index+1, sensingTime: sensingTime)
            transmitters.append(transmitter)
            channel.linkTransmitter(transmitter: transmitter)
        }
    }
    
    func runTransmitters() {
        for transmitter in transmitters {
            transmitter.transmitTo(channel)
        }
    }
    
    func logTransmitters() {
        for transmitter in transmitters {
            print(transmitter.id)
        }
    }
}

extension Environment {
    // MARK: Clock functions
    func cancelGlobalClock() {
        self.globalClock.upstream.connect().cancel()
    }
}
