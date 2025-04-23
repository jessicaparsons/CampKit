//
//  NotificationCenter+Extension.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/22/25.
//

import Foundation
import Combine


extension NotificationCenter {
    var storeDidChangePublisher: Publishers.ReceiveOn<NotificationCenter.Publisher, DispatchQueue> {
        return publisher(for: .cdcksStoreDidChange).receive(on: DispatchQueue.main)
    }
}
