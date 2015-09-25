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
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        window!.delegate = self
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
