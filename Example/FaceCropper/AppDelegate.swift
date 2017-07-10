//
//  AppDelegate.swift
//  FaceCropper
//
//  Created by KimDarren on 07/10/2017.
//  Copyright (c) 2017 KimDarren. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let screenBounds = UIScreen.main.bounds
    let window = UIWindow(frame: screenBounds)
    window.rootViewController = ExampleController()
    window.makeKeyAndVisible()
    self.window = window
    
    return true
  }
}

