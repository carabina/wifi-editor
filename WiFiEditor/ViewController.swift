//
//  ViewController.swift
//
//  Copyright (c) 2015 Vea Software. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate
{

    @IBOutlet weak var tableView: NSTableView!
    var networks = Dictionary<String, Dictionary<String, AnyObject>>()
    var objects  = NSMutableArray()
    var selected =  Set<String>()
    
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
        let path = "/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist"
        if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
            networks = dict["KnownNetworks"] as! Dictionary<String, Dictionary<String, AnyObject>>
            // Go through all the networks, getting the
            for (netName,networkVals) in networks {
                objects.addObject(netName)         // so we can have a sorted list
                for (propertyName, propertyVal) in (networkVals) {
                    if !ignoreSet.contains(propertyName){
                        networkProperties.insert(propertyName)
                    }
                }
            }
        }
        
        
        // Now add all the property names as colums
        for propertyName in networkProperties {
            var column = NSTableColumn()
            column.editable = false
            column.minWidth = 100
            column.headerCell = NSTableHeaderCell()
            column.headerCell.setObjectValue(propertyName)
            self.tableView.addTableColumn(column)
        }
        
        self.tableView.rowSizeStyle = NSTableViewRowSizeStyle.Default
        self.tableView.reloadData()
    }

    override var representedObject: AnyObject? {
            didSet {
        // Update the view, if already loaded.
        }
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.objects.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?
    {
        //var col = NSNumberFormatter().numberFromString(tableColumn!.title)
        //println("col="+String(col!.integerValue))
        
        tableColumn!.width = 40
        //var cellView = tableView.makeViewWithIdentifier("cell", owner: self) as! NSTableCellView
        
        
        if let title = tableColumn?.title {
            let networkName = objects.objectAtIndex(row) as! String
            if title == "select" {
                return selected.contains(networkName) || tableView.selectedRowIndexes.containsIndex(row)
            }
            let networkVals = networks[networkName]!
            if let val: AnyObject = networkVals[title]  {
                return "\(val)"
            }
        }
        return ""

        //cellView.textField!.stringValue = "\(pow(Double(row),col!.doubleValue))"
        
        //return cellView
    }
    
    func tableViewSelectionDidChange(notification: NSNotification)
    {
        if (self.tableView.numberOfSelectedRows > 0) {
            if let networkName = self.objects.objectAtIndex(self.tableView.selectedRow) as? String {
                if selected.contains(networkName){
                    selected.remove(networkName)
                } else {
                    selected.insert(networkName)
                }
            }
            self.tableView.deselectRow(self.tableView.selectedRow)
        }
        
    }
}

