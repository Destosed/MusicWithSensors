//
//  DefaultNetworkService.swift
//  MusicWithSensors
//
//  Created by Nikita Luzhbin on 19.06.2022.
//

// https://api.deezer.com/user/me/recommendations/tracks

import Foundation
import UIKit
import SafariServices

final class DefaultNetworkService {

    static let shared = DefaultNetworkService()

    private var accessToken: String?

    let accessTokenURL = "https://connect.deezer.com/oauth/access_token.php?app_id=547522&secret=4c489498e8956e6f74dab853145d8c9c&code="

    func getAuthToken(with code: String) async {
        let url = URL(string: self.accessTokenURL + code)!

        let (data, _) = try! await URLSession.shared.data(from: url)

        let accessTokenResponse = String(decoding: data, as: UTF8.self)

        let accessToken = accessTokenResponse.groups(for: "access_token=([a-zA-Z]+([0-9]+[a-zA-Z]+)+)&expires=")[0][1]

        self.accessToken = accessToken
    }
}

extension String {
    func groups(for regexPattern: String) -> [[String]] {
    do {
        let text = self
        let regex = try NSRegularExpression(pattern: regexPattern)
        let matches = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return matches.map { match in
            return (0..<match.numberOfRanges).map {
                let rangeBounds = match.range(at: $0)
                guard let range = Range(rangeBounds, in: text) else {
                    return ""
                }
                return String(text[range])
            }
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}
}
