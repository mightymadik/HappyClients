//
//  HapticsManager.swift
//  HappyClients
//
//  Created by MacBook on 13.04.2023.
//

import Foundation
import UIKit

class HapticsManager {
    static let shared = HapticsManager()

    private init() {}

    func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
