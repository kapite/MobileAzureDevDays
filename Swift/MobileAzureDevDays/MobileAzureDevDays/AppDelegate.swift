//
//  AppDelegate.swift
//  MobileAzureDevDays
//
//  Created by Colby Williams on 9/22/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import UIKit
import MobileCenter
import MobileCenterAnalytics
import MobileCenterCrashes

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        MSMobileCenter.start("0bb0de82-1811-4710-b434-ce78fb0a0d90", withServices:[
            MSAnalytics.self,
            MSCrashes.self
        ])
		return true
	}

	
	func applicationDidBecomeActive(_ application: UIApplication) {
        SentimentClient.shared.obtainKey(){keyResponse in
            if let document = keyResponse {
                SentimentClient.shared.apiKey = document.key
                SentimentClient.shared.region = document.region
                MSAnalytics.trackEvent("Key from API", withProperties: ["region":document.region])
            } else {
                MSAnalytics.trackEvent("Failed to get key from API")
                self.showApiKeyAlert(application)
            }
        }

	}

	func showApiKeyAlert(_ application: UIApplication) {
		
		if SentimentClient.shared.apiKey == nil || SentimentClient.shared.apiKey!.isEmpty {
			
			let alertController = UIAlertController(title: "Configure App", message: "Enter a Text Analytics API Subscription Key. Or add the key in code in `didFinishLaunchingWithOptions`", preferredStyle: .alert)
			
			alertController.addTextField() { textField in
				textField.placeholder = "Subscription Key"
				textField.returnKeyType = .done
			}
			
			alertController.addAction(UIAlertAction(title: "Get Key", style: .default) { a in
				if let getKeyUrl = URL(string: "https://portal.azure.com/#blade/HubsExtension/BrowseResourceBlade/resourceType/Microsoft.CognitiveServices%2Faccounts") {
					UIApplication.shared.open(getKeyUrl, options: [:]) { opened in
						print("Opened GetKey url successfully: \(opened)")
					}
				}
			})
			
			alertController.addAction(UIAlertAction(title: "Done", style: .default) { a in
				if alertController.textFields?.first?.text == nil || alertController.textFields!.first!.text!.isEmpty {
					self.showApiKeyAlert(application)
				} else {
					SentimentClient.shared.apiKey = alertController.textFields!.first!.text
				}
			})
		
			window?.rootViewController?.present(alertController, animated: true) { }
		}
	}
}

