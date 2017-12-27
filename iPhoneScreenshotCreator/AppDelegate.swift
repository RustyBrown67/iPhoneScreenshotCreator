//
//  AppDelegate.swift
//  iPhoneScreenshotCreator
//
//  Created by Russell Brown on 27/12/2017.
//  Copyright © 2017 Russell Brown. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // To display an opacity for the selected colour
        NSColorPanel.shared.showsAlpha = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

