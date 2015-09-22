//
//  WifiModel.swift
//  WiFi Editor
//
//  Created by Simson Garfinkel on 9/21/15.
//  Copyright © 2015 Nitroba. All rights reserved.
//

import Foundation

@objc
class WifiModel:NSObject {
    var networks = Dictionary<String, Dictionary<String, AnyObject>>()
    var airport_preferences = Dictionary<String, AnyObject>()
    var dirty = true
    let airport_preferences_fname = "/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist"

    func loadNetworks() {
        if let dict = NSDictionary(contentsOfFile: airport_preferences_fname) as? Dictionary<String, AnyObject> {
            airport_preferences = dict
            networks = dict["KnownNetworks"] as! Dictionary<String, Dictionary<String, AnyObject>>
        } else {
        }
    }
    
    func matchingNetworks(s:String) -> Array<String> {
        let ret = NSMutableArray()
        for (netName,networkVals) in networks {
            for (_,val) in networkVals {
                if let val_string = val as? String {
                    if s=="" || (val_string.lowercaseString.rangeOfString(s.lowercaseString) != nil) {
                        ret.addObject(netName)
                    }
                }
            }
        }
        return ret as AnyObject as! [String];
    }
    
    func deleteNetwork(s:String) {
        networks.removeValueForKey(s)
    }
    
    func save() {
        let d = airport_preferences as NSDictionary
        let fname = NSTemporaryDirectory() + "/preferences.new"
        d.writeToFile(fname,atomically:false)
        print("written to",fname)
        
        let old_signal = signal(SIGPIPE,SIG_IGN)
        let data =  NSData(contentsOfFile: fname)
        let task = NSTask()
        task.launchPath = "/usr/libexec/authopen"
        task.arguments = ["-c","-w","/etc/xxx-3"]
        let pipe = NSPipe()
        task.standardInput = pipe
        task.launch()
        pipe.fileHandleForWriting.writeData(data!)
        pipe.fileHandleForWriting.closeFile()
        task.waitUntilExit()
        signal(SIGPIPE,old_signal)
    }
}

