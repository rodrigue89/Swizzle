//
//  AppDelegate.swift
//  Swizzle - Compiling
//
//  Created by Ethan Uppal on 1/13/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Cocoa

protocol LoggerDelegate: class {
    func log()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    static weak var logDelegate: LoggerDelegate?

    @IBAction func log(_ sender: NSMenuItem) {
        AppDelegate.logDelegate?.log()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

