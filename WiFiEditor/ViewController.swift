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

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate
{

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var totalNetworksCell: NSTextField!
    @IBOutlet weak var totalSelectedCell: NSTextField!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var statusField: NSTextField!
    var model:WifiModel!
    
    var displayedNetworks  = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = (NSApp.delegate as! AppDelegate).model
        
        model.loadNetworks()
        
        // See what properties we should ignore
        var ignoreSet = Set<String>()
        if let path = NSBundle.mainBundle().pathForResource("config", ofType: "plist") {
            if let config = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                let ignoreArray = config["ignore"] as! Array<String>
                ignoreSet = Set<String>(ignoreArray)
            }
        }
        var networkProperties = Set<String>()
        totalNetworksCell!.integerValue = model.networks.count

            // Go through all the networks, getting the property names
         for (_,networkVals) in model.networks {
            for (propertyName, _) in (networkVals) {
                if !ignoreSet.contains(propertyName){
                    networkProperties.insert(propertyName)
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
        displayedNetworks = model.matchingNetworks(s)
        totalNetworksCell.integerValue = model.networks.count
        self.tableView.reloadData()
    }
    
    @IBAction func search(sender: NSSearchField) {
        displayNetworksMatching(sender.stringValue)
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.displayedNetworks.count
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = tableColumn!.identifier
        let networkName = displayedNetworks[row]
        let networkVals = model.networks[networkName]!
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
    
//    func tableViewSelectionDidChange(notification: NSNotification)
//    {
//        view.window!.delegate = self
//    
//        if (self.tableView.numberOfSelectedRows > 0) {
//            if let networkName = self.displayedNetworks.objectAtIndex(self.tableView.selectedRow) as? String {
//                if selectedNetworks.contains(networkName){
//                    selectedNetworks.remove(networkName)
//                } else {
//                    selectedNetworks.insert(networkName)
//                }
//            }
//            //self.tableView.deselectRow(self.tableView.selectedRow)
//        }
//    }

    @IBAction func save(sender: NSControl) {
        model.save()
    }
    
    @IBAction func deleteSelected(sender: NSButton) {
        // Build a set of the network names to delete
        let toDelete = NSMutableSet()
        for i in self.tableView.selectedRowIndexes {
            toDelete.addObject(displayedNetworks[i])
        }
        // remove them from what's displayed
        displayedNetworks = displayedNetworks.filter({!toDelete.containsObject($0)})
        // remove them from the model
        for obj in toDelete {
            model.deleteNetwork(obj as! String)
            view.window!.documentEdited=true
        }
        tableView.reloadData()
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
    
    func windowWillClose(notification: NSNotification) {
        NSApp.terminate(self)
    }
}

