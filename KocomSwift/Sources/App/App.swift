//
//  App.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation

final class App {
    private var rs485Service: RS485Service!
    private var mqttService: MQTTService!
    private var discoveryService: DiscoveryService!
    
    private init() { }
    static let shared = App()

    func initialize() throws {
        let mqttService = try MQTTService()
        let rs485Service = try RS485Service(mqttService: mqttService)
        
        self.mqttService = mqttService
        self.rs485Service = rs485Service
        
        self.discoveryService = DiscoveryService(mqttService: mqttService)
    }
    
    func start() throws {
        try self.mqttService.connect()
        try self.rs485Service.connect()
    }
}
