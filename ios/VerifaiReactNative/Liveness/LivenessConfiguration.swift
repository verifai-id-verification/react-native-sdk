//
//  LivenessConfiguration.swift
//  verifai-react-native
//
//  Created by Richard Chirino on 01/02/2022.
//

import Foundation
import VerifaiLivenessKit

struct LivenessConfiguration {
    var nativeConfiguration = VerifaiLivenessCheckConfiguration()

    init(configuration: NSDictionary) throws {
        // Whether the dismiss button should be shown
        if let showDismissButton = configuration.value(forKey: "showDismissButton") as? Bool {
            self.nativeConfiguration.showDismissButton = showDismissButton
        }
        // Custom dismiss button title string, iOS only
        if let customDismissButtonTitle = configuration.value(forKey: "customDismissButtonTitle") as? String {
            self.nativeConfiguration.customDismissButtonTitle = customDismissButtonTitle
        }
        // Whether the check skip button should be shown
        if let showSkipButton = configuration.value(forKey: "showSkipButton") as? Bool {
            self.nativeConfiguration.showSkipButton = showSkipButton
        }
        // Custom skip button title string
        if let customSkipButtonTitle = configuration.value(forKey: "customSkipButtonTitle") as? String {
            self.nativeConfiguration.customSkipButtonTitle = customSkipButtonTitle
        }
        // Where the check videos should be stored, iOS only
        if let resultPath = configuration.value(forKey: "resultPath") as? String {
            self.nativeConfiguration.resultPath = URL(fileURLWithPath: resultPath)
        }
    }

}
