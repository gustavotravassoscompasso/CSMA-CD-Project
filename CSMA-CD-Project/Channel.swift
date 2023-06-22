//
//  Channel.swift
//  CSMA-CD-Project
//
//  Created by Gustavo Igor Goncalves Travassos on 19/06/23.
//

import Foundation

final class Channel {
    var linkedTransmitters: [Transmitter] = []
    var status: Status = .available
    
    var control: Int = 0
    
    func linkTransmitter(transmitter: Transmitter) {
        transmitter.delegate = self
        linkedTransmitters.append(transmitter)
    }
    
    func verifyCrashs() {
        if control > 1 {
            print("[Canal de transmissão] - Ocorreu um crash! Notifiying all transmitters\n")
            NotificationCenter.default.post(name: Notification.Name("Crash"), object: nil)
            resetChannel()
        }
    }
    
    func resetChannel() {
        status = .available
        control = 0
    }
}

// MARK: Transmission Protocol
extension Channel: TransmissionProtocol {
    func transmitterWillSendData(id: Int) {
        print("[Canal de transmissão] - Transmissor \(id) está se preparando para enviar dados\n")
        status = .unavailable
        control+=1
        NotificationCenter.default.post(name: Notification.Name("Transmitter\(id)TransmissionConfirmed"), object: nil)
    }
    
    func sendFakeData(id: Int) {
        print("[Canal de transmissão] - Dados recebidos do [Transmissor \(id)]\n")
        NotificationCenter.default.post(name: Notification.Name("Transmitter\(id)TransmissionFinished"), object: nil)
        resetChannel()
    }
}

extension Channel {
    // MARK: Channel Status
    enum Status: String {
        case available = "Available"
        case unavailable = "Unavailable"
    }
}
