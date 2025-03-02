//
//  Settings.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation

/// 메인 번들에서 Info.plist를 읽어오는 클래스
final class InfoPlistReader {
    
    /// Info.plist에 명시된 키
    enum InfoPlistKey: String, CaseIterable {
        case RS485_HOST
        case RS485_PORT
        case MQTT_HOST
        case MQTT_PORT
        case MQTT_USERNAME
        case MQTT_PASSWORD
    }
    
    /// Info.plist에서 키에 해당하는 값을 반환
    /// - Parameter key: Info.plist 키
    /// - Returns: 키에 해당하는 값
    static func value<T>(for key: InfoPlistKey) -> T? {
        return Bundle.main.infoDictionary?[key.rawValue] as? T
    }
    
    /// Info.plist 값을 읽어들일 수 있는지 확인
    /// - throws: ``InfoPlistError``
    static func checkEnvironmentValues() throws {
        try InfoPlistKey.allCases.forEach { key in
            guard let _: Any? = InfoPlistReader.value(for: key)
            else {
                throw InfoPlistError.missingKey
            }
        }
    }
    
    enum InfoPlistError: Error {
        /// Info.plist에서 값을 찾는데 실패함
        case missingKey
    }
}
