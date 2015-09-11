//
//  ViewController.swift
//
//  Copyright (c) 2015 Vea Software. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate
{

    @IBOutlet weak var tableView: NSTableView!
    var networks = Dictionary<String, AnyObject>()
    var networkProperties = Set<String>()
    var objects: NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        


        let path = "/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist"
        if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
            networks = dict["KnownNetworks"] as! Dictionary<String, AnyObject>
            
            // Go through all the networks, getting the
            for (netName,vals) in networks {
                objects.addObject(vals)         // so we can have a sorted list
                println(vals)
                let valDict = vals as! Dictionary<String, AnyObject>
                for (propertyName, propertyVal) in (valDict) {
                        networkProperties.insert(propertyName)
                }
            }
        }
        
        // Now add all the property names as colums
        for propertyName in networkProperties {
            var column = NSTableColumn()
            column.headerCell = NSTableHeaderCell()
            column.headerCell.setObjectValue(propertyName)
            self.tableView.addTableColumn(column)
        }
        
        //tableView.tableColumns[1].headerCell!.stringValue = "two" as! String
        //self.tableView.rowHeight = 15
        self.tableView.rowSizeStyle = NSTableViewRowSizeStyle.Default
        
        
        self.tableView.reloadData()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
            didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: - Table View
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.objects.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        //var col = NSNumberFormatter().numberFromString(tableColumn!.title)
        //println("col="+String(col!.integerValue))
        
        var cellView = tableView.makeViewWithIdentifier("cell", owner: self) as! NSTableCellView
        
        let network = objects.objectAtIndex(row) as! Dictionary<String, AnyObject>
        
        //if let val = network[tableColumn!.title] as? String {
        //    cellView.textField!.stringValue = val
        //} else {
        cellView.textField?.alignment = NSTextAlignment.LeftTextAlignment
        cellView.textField!.stringValue = ""
        if let val: AnyObject = network[tableColumn!.title]  {
            cellView.textField!.stringValue = "\(val)"
        }

        //cellView.textField!.stringValue = "\(pow(Double(row),col!.doubleValue))"
        
        return cellView
    }
    
    func tableViewSelectionDidChange(notification: NSNotification)
    {
        //if (self.tableView.numberOfSelectedRows > 0) {
        //    let selectedItem = self.objects.objectAtIndex(self.tableView.selectedRow) as! String
        //
        //    println(selectedItem)
        //
        //    //self.tableView.deselectRow(self.tableView.selectedRow)
        //}
        
    }

}

