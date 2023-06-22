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
    
    var status: Status = .waitingSensingTime
    
    var sensingTime: Int
    var backoffAttemptsCount: Int = 0
    var backoffMaxAttempts: Int = 3
    
    init(delegate: TransmissionProtocol? = nil, id: Int, sensingTime: Int) {
        self.delegate = delegate
        self.id = id
        self.sensingTime = sensingTime
        
        NotificationCenter.default.addObserver(self, selector: #selector(channelReportedCrash(notification:)), name: Notification.Name("Crash"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.channelConfirmedTransmission(notification:)), name: Notification.Name("Transmitter\(id)TransmissionConfirmed"), object: nil)
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
            
        case .waitingSensingTime:
            waitSensingTime()
        }
    }

    func checkChannel(_ channel: Channel) {
        print("[Transmissor \(self.id)] - Vericando o canal de transmissão")
        
        if channel.status == .available {
            print("[Transmissor \(self.id)] - Canal Disponível!\n")
            self.status = .prepareToTransmit
        }
        
        if channel.status == .unavailable {
            print("[Transmissor \(self.id)] - Canal Ocupado\n")
        }
    }
    
    func transmitting() {
        print("[Transmissor \(self.id)] - Transmitindo no canal\n")
        self.status = .transmitData
        self.backoffAttemptsCount = 0
    }
    
    func transmitData() {
        self.delegate?.sendFakeData(id: self.id)
        self.sensingTime = Int.random(in: 0...10)
    }
    
    @objc func channelReportedCrash(notification: Notification) {
        self.status = .channelCrashed
    }
    
    @objc func channelConfirmedTransmission(notification: Notification) {
        self.status = .transmitting
    }
    
    func backoff() {
        print("[Transmissor \(self.id)] - Iniciando Backoff")
        
        if backoffAttemptsCount >= backoffMaxAttempts {
            fatalError("[Transmissor \(self.id)] - Quantidade máxima de backoffs atingida\n")
        }
        
        let newRange = Int(pow(2, Double(self.backoffAttemptsCount)))
        sensingTime = Int.random(in: 1...newRange+1)
        print("[Transmissor \(self.id)] - Tempo de backoff: \(sensingTime)\n")
        backoffAttemptsCount+=1
        
        self.status = .waitingSensingTime
    }
    
    func waitSensingTime() {
        print("[Transmissor \(self.id)] - Aguardando tempo de sensing: \(sensingTime)\n")
        if sensingTime == 0 {
            self.status = .checkingChannel
        } else {
            sensingTime-=1
        }
    }
}

extension Transmitter {
    // MARK: Trasmitter Status
    enum Status: String {
        case checkingChannel = "Checking Channel"
        case prepareToTransmit = "Prepare to Transmit"
        case transmitting = "Transmitting"
        case transmitData = "transmitData"
        case channelCrashed = "Channel Crashed"
        case mustPerformBackoff = "Must Perform Backoff"
        case waitingSensingTime = "Waiting sensing time"
    }
}
