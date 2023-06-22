//
//  Transmitter.swift
//  CSMA-CD-Project
//
//  Created by Gustavo Igor Goncalves Travassos on 19/06/23.
//

import Foundation

protocol TransmissionProtocol: AnyObject {
    func transmitterWillSendData(id: Int)
    func sendFakeData(id: Int)
}

final class Transmitter {
    weak var delegate: TransmissionProtocol?
    
    let id: Int
    let clock = ContinuousClock()
    
    var status: Status = .waiting
    
    var sensingTime: Int
    var timeRemaining: Int
    var backoffAttemptsCount: Int = 0
    var backoffMaxAttempts: Int = 3
    var backoffTime: Int = 0
    var backoffPower: Int = 2
    
    init(delegate: TransmissionProtocol? = nil, id: Int, sensingTime: Int) {
        self.delegate = delegate
        self.id = id
        self.sensingTime = sensingTime
        self.timeRemaining = sensingTime
        
        NotificationCenter.default.addObserver(self, selector: #selector(channelReportedCrash(notification:)), name: Notification.Name("Crash"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.channelConfirmedTransmission(notification:)), name: Notification.Name("Transmitter\(id)TransmissionConfirmed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.channelFinishedTransmission(notification:)), name: Notification.Name("Transmitter\(id)TransmissionFinished"), object: nil)
    }
    
    func transmitTo(_ channel: Channel) {
        switch status {
        case .checkingChannel:
            checkChannel(channel)
            
        case .prepareToTransmit:
            self.delegate?.transmitterWillSendData(id: self.id)
            
        case .transmitting:
            transmitting()
            
        case .transmitData:
            transmitData()
            
        case .channelCrashed:
            self.status = .mustPerformBackoff
            
        case .mustPerformBackoff:
            backoff()
            
        case .waiting:
            waitTimeRemaining()
        }
    }

    func checkChannel(_ channel: Channel) {
        print("[Transmissor \(self.id)] - Vericando o canal de transmissão")
        
        if channel.status == .available {
            print("[Transmissor \(self.id)] - Canal Disponível!\n")
            self.status = .prepareToTransmit
        }
        
        else if channel.status == .unavailable {
            print("[Transmissor \(self.id)] - Canal Ocupado\n")
        }
    }
    
    func transmitting() {
        print("[Transmissor \(self.id)] - Transmitindo no canal\n")
        self.status = .transmitData
    }
    
    func transmitData() {
        self.delegate?.sendFakeData(id: self.id)
    }
    
    func backoff() {
        print("[Transmissor \(self.id)] - Entrando em Backoff")
        
        if backoffAttemptsCount >= backoffMaxAttempts {
            fatalError("[Transmissor \(self.id)] - Quantidade máxima de backoffs atingida\n")
        } else if backoffTime == 0 {
            self.backoffTime = Int.random(in: 1...10)
            self.timeRemaining = backoffTime
        } else {
            self.backoffTime = getNewBackoffTime()
            self.timeRemaining = backoffTime
        }
        
        print("[Transmissor \(self.id)] - Tempo de backoff: \(timeRemaining)\n")
        backoffAttemptsCount+=1
        
        self.status = .waiting
    }
    
    func getNewBackoffTime() -> Int {
        let getNewBackoffTime = Int(pow(Double(self.backoffTime), Double(self.backoffPower)))
        self.backoffPower = Int(pow(Double(backoffPower), 2.0))
        return getNewBackoffTime
    }
    
    func waitTimeRemaining() {
        print("[Transmissor \(self.id)] - Aguardando tempo restante: \(timeRemaining)\n")
        if timeRemaining == 0 {
            self.status = .checkingChannel
        } else {
            timeRemaining-=1
        }
    }
}

// MARK: Notification Center Functions
extension Transmitter {
    @objc func channelReportedCrash(notification: Notification) {
        self.status = .channelCrashed
    }
    
    @objc func channelConfirmedTransmission(notification: Notification) {
        self.status = .transmitData
    }
    
    @objc func channelFinishedTransmission(notification: Notification) {
        self.timeRemaining = sensingTime
        self.backoffAttemptsCount = 0
        self.status = .waiting
    }
}

extension Transmitter {
    // MARK: Trasmitter Status
    enum Status: String {
        case checkingChannel = "Checking Channel"
        case prepareToTransmit = "Prepare to Transmit"
        case transmitting = "Transmitting"
        case transmitData = "Transmitting Data"
        case channelCrashed = "Channel Crashed"
        case mustPerformBackoff = "Must Perform Backoff"
        case waiting = "Waiting time"
    }
}
