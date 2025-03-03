//
//  CommonJSONEncoder.swift
//  KocomSwift
//
//  Created by 최광현 on 3/4/25.
//

import Foundation

/// JSON 프리티, 키정렬 기본으로 가집니다.
final class CommonJSONEncoder: JSONEncoder, @unchecked Sendable {
    override init() {
        super.init()
        self.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
}
