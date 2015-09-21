//
//  ViewController.swift
//
//  Copyright (c) 2015 Vea Software. All rights reserved.
//
// http://stackoverflow.com/questions/13553935/nstableview-to-allow-user-to-choose-which-columns-to-display
// http://stackoverflow.com/questions/19801271/how-can-i-make-command-a-select-all-the-nstextview-text-in-rows-in-an-nstablevie

// https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/authopen.1.html#//apple_ref/doc/man/1/authopen

import Cocoa
import Foundation

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate
{

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var totalNetworksCell: NSTextField!
    @IBOutlet weak var totalSelectedCell: NSTextField!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var statusField: NSTextField!
    

    var networks = Dictionary<String, Dictionary<String, AnyObject>>()
    var displayedNetworks  = NSMutableArray()
    var selectedNetworks =  Set<String>()
    var airport_preferences = Dictionary<String, AnyObject>()
    let airport_preferences_fname = "/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var ignoreSet = Set<String>()
        if let path = NSBundle.mainBundle().pathForResource("config", ofType: "plist") {
            if let config = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                let ignoreArray = config["ignore"] as! Array<String>
                ignoreSet = Set<String>(ignoreArray)
            }
        }
        var networkProperties = Set<String>()
        if let dict = NSDictionary(contentsOfFile: airport_preferences_fname) as? Dictionary<String, AnyObject> {
            airport_preferences = dict
            networks = dict["KnownNetworks"] as! Dictionary<String, Dictionary<String, AnyObject>>
            totalNetworksCell!.integerValue = networks.count

            // Go through all the networks, getting the property names
            for (_,networkVals) in networks {
                for (propertyName, _) in (networkVals) {
                    if !ignoreSet.contains(propertyName){
                        networkProperties.insert(propertyName)
                    }
                }
            }
        }
        
        // Now add all the property names as colums
        //for propertyName in networkProperties {
        //    let column = NSTableColumn(identifier: propertyName)
        //    column.width = 50
        //    column.title = propertyName
        //    column.editable = false
        //    self.tableView.addTableColumn(column)
        //}
        self.tableView.reloadData()
        displayNetworksMatching("")
    }

    
    func displayNetworksMatching(s:String) {
        displayedNetworks.removeAllObjects()
        for (netName,networkVals) in networks {
            for (_,val) in networkVals {
                if let val_string = val as? String {
                    if s=="" || (val_string.lowercaseString.rangeOfString(s.lowercaseString) != nil) {
                        displayedNetworks.addObject(netName)
                        break
                    }
                }
            }
        }
        totalNetworksCell.integerValue = networks.count
        self.tableView.reloadData()
    }
    
    @IBAction func search(sender: NSSearchField) {
        displayNetworksMatching(sender.stringValue)
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.displayedNetworks.count
    }

   
    //if title == "select" {
    //    return selectedNetworks.contains(networkName) || tableView.selectedRowIndexes.containsIndex(row)
    //}
 
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = tableColumn!.identifier
        let networkName = displayedNetworks.objectAtIndex(row) as! String
        let networkVals = networks[networkName]!
        if let val: AnyObject = networkVals[identifier]  {
            var obj = tableView.makeViewWithIdentifier(identifier, owner:self)
            if (obj==nil) {
                // No existing cell to reuse, so make a new one
                // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TableView/PopulatingView-TablesProgrammatically/PopulatingView-TablesProgrammatically.html#//apple_ref/doc/uid/10000026i-CH14-SW1
                obj = NSTableCellView(frame:NSMakeRect(0,0,100,100))
                obj!.identifier = identifier
            }
            let cellView = obj as! NSTableCellView
            cellView.textField!.stringValue = "\(val)"
            return cellView
        }
        return nil
    }
    
    func tableViewSelectionDidChange(notification: NSNotification)
    {
        if (self.tableView.numberOfSelectedRows > 0) {
            if let networkName = self.displayedNetworks.objectAtIndex(self.tableView.selectedRow) as? String {
                if selectedNetworks.contains(networkName){
                    selectedNetworks.remove(networkName)
                } else {
                    selectedNetworks.insert(networkName)
                }
            }
            //self.tableView.deselectRow(self.tableView.selectedRow)
        }
        
    }
    @IBAction func save(sender: NSControl) {
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
    
    @IBAction func deleteSelected(sender: NSButton) {
        for i in self.tableView.selectedRowIndexes {
            print("row",i,"is selected",displayedNetworks[i],networks[displayedNetworks[i] as! String])
        }
        
    }
    
}

