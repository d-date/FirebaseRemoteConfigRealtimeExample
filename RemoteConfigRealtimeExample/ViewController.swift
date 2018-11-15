//
//  ViewController.swift
//  RemoteConfigRealtimeExample
//
//  Created by Daiki Matsudate on 2018/11/14.
//  Copyright © 2018 Daiki Matsudate. All rights reserved.
//

import UIKit
import Firebase

@objc(ViewController)
class ViewController: UIViewController {

  let welcomeMessageConfigKey = "welcome_message"
  let welcomeMessageCapsConfigKey = "welcome_message_caps"
  let loadingPhraseConfigKey = "loading_phrase"

  var remoteConfig: RemoteConfig!
  @IBOutlet weak var welcomeLabel: UILabel!
  @IBOutlet weak var fetchButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    remoteConfig = RemoteConfig.remoteConfig()
    remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    fetchConfig()

    NotificationCenter.default.addObserver(self, selector: #selector(fetchConfig), name: .init("stale"), object: nil)
  }

  @objc func fetchConfig() {
    welcomeLabel.text = remoteConfig[loadingPhraseConfigKey].stringValue

    var expirationDuration = 43200 // 12 hours in seconds.
    // If your app is using developer mode or cache is stale, cacheExpiration is set to 0,
    // so each fetch will retrieve values from the service.

    if remoteConfig.configSettings.isDeveloperModeEnabled || UserDefaults.standard.bool(forKey: "CONFIG_STALE") {
      expirationDuration = 0
      UserDefaults.standard.set(false, forKey: "CONFIG_STALE")
    }

    remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in

      let alertAction: UIAlertAction = .init(title: "OK", style: .default, handler: nil)

      switch status {
      case .success:
        print("Config fetched!")
        let alertController: UIAlertController = .init(title: "Fetch Success", message: nil, preferredStyle: .alert)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)

        // After config data is successfully fetched, it must be activated before newly fetched
        // values are returned.
        self.remoteConfig.activateFetched()
      case .noFetchYet:
        break
      case .throttled:
        print("Config throttled")
        let alertController: UIAlertController = .init(title: "Fetch Throttled", message: nil, preferredStyle: .alert)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)

        print("Error: \(error?.localizedDescription ?? "No error available.")")
      case .failure:
        print("Config not fetched")
        let alertController: UIAlertController = .init(title: "Fetch Failed", message: nil, preferredStyle: .alert)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)

        print("Error: \(error?.localizedDescription ?? "No error available.")")

      }
      self.displayWelcome()
    }
  }

  func displayWelcome() {
    var welcomeMessage = remoteConfig[welcomeMessageConfigKey].stringValue

    if remoteConfig[welcomeMessageCapsConfigKey].boolValue {
      welcomeMessage = welcomeMessage?.uppercased()
    }
    welcomeLabel.text = welcomeMessage
  }

  @IBAction func handleFetchTouch(_ sender: AnyObject) {
    fetchConfig()
  }
}
