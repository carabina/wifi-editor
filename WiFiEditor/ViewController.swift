//
//  ViewController.swift
//
//  Copyright (c) 2015 Vea Software. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate
{

    @IBOutlet weak var tableView: NSTableView!
    var objects: NSMutableArray! = NSMutableArray()
    var networks = Dictionary<String, AnyObject>()
    var networkProperties = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let path = "/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist"
        if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
            networks = dict["KnownNetworks"] as! Dictionary<String, AnyObject>
            
            for (net,vals) in networks {
                let valDict = vals as! Dictionary<String, AnyObject>
                for (propertyName, propertyVal) in (valDict) {
                        networkProperties.insert(propertyName)
                }
            }
        }
        
        // Now add all the property names
        for propertyName in networkProperties {
            var column = NSTableColumn()
            column.headerCell = NSTableHeaderCell()
            column.headerCell.setObjectValue(propertyName)
            self.tableView.addTableColumn(column)
        }
        
        println("Table columns "+String(self.tableView.tableColumns.count))
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
        cellView.textField!.stringValue = self.objects.objectAtIndex(row) as! String
        //cellView.textField!.stringValue = "\(pow(Double(row),col!.doubleValue))"
        
        return cellView
    }
    
    func tableViewSelectionDidChange(notification: NSNotification)
    {
        if (self.tableView.numberOfSelectedRows > 0) {
            let selectedItem = self.objects.objectAtIndex(self.tableView.selectedRow) as! String
            
            println(selectedItem)
            
            //self.tableView.deselectRow(self.tableView.selectedRow)
        }
        
    }

}

