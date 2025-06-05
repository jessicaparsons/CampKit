//
//  AppInfo.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/28/25.
//

import Foundation

struct AppInfo {
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    static var versionWithBuild: String {
        "\(version)"
    }
}
