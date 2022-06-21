//
//  DefaultApplicationCoordinator.swift
//  MusicWithSensors
//
//  Created by Nikita Luzhbin on 19.06.2022.
//

import Foundation
import UIKit

final class DefaultApplicationCoordinator {

    func handle(url: URL) {
        var dict: [String : String] = [:]

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        if let queryItems = components.queryItems {
            for item in queryItems {
                dict[item.name] = item.value!
            }
        }

        if let authCode = dict["code"] {
            NotificationCenter.default.post(name: .init(rawValue: "didRecieveUAuthCode"), object: authCode)
        }
    }
}
