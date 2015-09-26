//
//  WindowController.swift
//  WiFi Editor
//
//  Created by Simson Garfinkel on 9/23/15.
//  Copyright © 2015 Nitroba. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {
    var model:WifiModel!

    override func windowDidLoad() {
        super.windowDidLoad()
        model = (NSApp.delegate as! AppDelegate).model  // get the model
    }
    
    func windowWillClose(notification: NSNotification) {
        NSApp.terminate(self)
    }

    func windowShouldClose(sender: AnyObject) -> Bool {
        if model.dirty {
            let alert = NSAlert()
            alert.messageText = "Save Changes?"
            alert.addButtonWithTitle("Yes")
            alert.addButtonWithTitle("No")
            alert.informativeText = "You have made changes, do you want to discard them?"
            if alert.runModal() == NSAlertFirstButtonReturn {
                return true;
            }
            return false
        }
        return true
    }
    
}
