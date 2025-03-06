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
    private var HomeAssistantService: HomeAssistantService!
    
    private init() { }
    static let shared = App()

    func initialize() throws {
        self.rs485Service = try RS485Service.initialize()
        self.HomeAssistantService = HomeAssistantService()
        
        let mqttService = try MQTTService(
            rs485Service: self.rs485Service,
            discovery: self.HomeAssistantService
        )
        
        self.mqttService = mqttService
        
        self.HomeAssistantService.setMQTTService(mqttService: mqttService)
        self.rs485Service.setHomeassistantService(self.HomeAssistantService)
    }
    
    func start() throws {
        try self.mqttService.connect()
        try self.rs485Service.connect()
    }
}
