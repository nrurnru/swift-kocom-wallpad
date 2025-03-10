//
//  Logging.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation
import OSLog

final class Logging {
    enum LogLevel: Int {
        case debug
        case info
        
        case error
    }
    
    public static let shared = Logging()
    
    private var logLevel: LogLevel = .info
    
    /// 로그 레벨 설정
    /// - Parameter level: 설정할 로그 레벨, 기본값은 info 입니다.
    func setLogLevel(_ level: LogLevel) {
        self.logLevel = level
    }
    
    /// OS레벨 로깅
    /// - Parameters:
    ///   - message: 로깅할 메시지
    ///   - level: 로깅 레벨
    func log(
        _ message: String,
        level: LogLevel = .info,
        file: String = #fileID,
        line: Int = #line
    ) {
        let d = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let date = formatter.string(from: d)
        
        let obj = file.split(separator: "/").last?.replacingOccurrences(
            of: ".swift",
            with: ""
        ) ?? ""
        
        let message: String = "\(date) [\(obj)] \(message)"
        
        if #available(macOS 11, *), #available(iOS 14, *) {
            switch (level, self.logLevel.rawValue) {
                case (LogLevel.debug, ...LogLevel.debug.rawValue):
                    Logger().debug("\(message)")
                case (LogLevel.info, ...LogLevel.info.rawValue):
                    Logger().info("\(message)")
                case (LogLevel.error, ...LogLevel.error.rawValue):
                    Logger().error("\(message)")
                default:
                    return
            }
        } else {
            print(message)
        }
    }
}
            
