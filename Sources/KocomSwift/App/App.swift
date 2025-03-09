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
    private var homeAssistantService: HomeAssistantService!
    private var commandSendService: CommandSendService!
    
    private init() { }
    static let shared = App()

    func initialize() throws {
        self.rs485Service = try RS485Service.initialize()
        self.homeAssistantService = HomeAssistantService()
        
        self.commandSendService = DefaultCommandSendService(rs485Service: self.rs485Service)
        
        let mqttService = try MQTTService(
            rs485Service: self.rs485Service,
            homeAssistantService: self.homeAssistantService,
            commandSendService: self.commandSendService
        )
        
        self.mqttService = mqttService
        
        self.homeAssistantService.setMQTTService(mqttService: mqttService)
        self.rs485Service.setHomeassistantService(self.homeAssistantService)
    }
    
    func start() throws {
        try self.mqttService.connect()
        try self.rs485Service.connect()
    }
}
