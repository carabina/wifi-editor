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

        // get the model
        model = (NSApp.delegate as! AppDelegate).model
        model.loadNetworks()
        
        // See what properties we should ignore
//        var ignoreSet = Set<String>()
//        if let path = NSBundle.mainBundle().pathForResource("config", ofType: "plist") {
//            if let config = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
//                let ignoreArray = config["ignore"] as! Array<String>
//                ignoreSet = Set<String>(ignoreArray)
//            }
//        }
//        var networkProperties = Set<String>()
//        totalNetworksCell!.integerValue = model.networks.count
//
//            // Go through all the networks, getting the property names
//         for (_,networkVals) in model.networks {
//            for (propertyName, _) in (networkVals) {
//                if !ignoreSet.contains(propertyName){
//                    networkProperties.insert(propertyName)
//                }
//            }
//        }
        
       
        // Now add all the property names as colums
        //for propertyName in networkProperties {
        //    let column = NSTableColumn(identifier: propertyName)
        //    column.width = 50
        //    column.title = propertyName
        //    column.editable = false
        //    self.tableView.addTableColumn(column)
        //}
        //self.tableView.reloadData()
        if let sd = tableView.tableColumnWithIdentifier("SSIDString")?.sortDescriptorPrototype {
            tableView.sortDescriptors=[sd]
            model.sortDescriptors = tableView.sortDescriptors
        }
        displayNetworksMatching("")
        
        // Now size each of the rows
        for column in tableView.tableColumns {
            column.sizeToFit()               // size to width of title
            var maxWidth = column.width
            for row in 0..<displayedNetworks.count {
                if let cell = self.tableView(tableView, viewForTableColumn:column, row:row)  {
                    let ct = cell as! NSTableCellView
                    maxWidth = max(maxWidth,ct.textField!.intrinsicContentSize.width)
                }
            }
            column.width = maxWidth        // size to width of title or text plus a buffer
        }
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
                obj = NSTableCellView(frame:NSMakeRect(0,0,400,400))
                obj!.identifier = identifier
            }
            let cellView = obj as! NSTableCellView
            cellView.textField!.stringValue = "\(val)"
            return cellView
        }
        return nil
    }
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        model.sortDescriptors = tableView.sortDescriptors
        displayNetworksMatching(searchField.stringValue) // do another sort
    }
    
    
    func selectedNetworks() -> Array<String> {
        return tableView.selectedRowIndexes.map({displayedNetworks[$0]})
    }

    @IBAction func copy(sender: NSControl){
        let strValue = "\(selectedNetworks().map({model.networks[$0]!}))"
        let pasteBoard = NSPasteboard.generalPasteboard()
        pasteBoard.clearContents()
        pasteBoard.writeObjects([strValue])
    }
    
    @IBAction func save(sender: NSControl) {
        model.save()
    }
    
    @IBAction func saveAs(sender: NSControl) {
        let pan = NSSavePanel()
        let ret = pan.runModal()
        if ret == NSFileHandlingPanelOKButton {
            print("save",pan.URL?.path)
        }
    }
    
    // http://techone.xyz/using-nstableview-animations-with-bindings/
    
    @IBAction func delete(sender: NSButton) {
        // Build a set of the network names to delete
        let selectedRows = self.tableView.selectedRowIndexes
        let toDelete = NSMutableSet()
        for i in selectedRows {
            toDelete.addObject(displayedNetworks[i])
            self.tableView.deselectRow(i)
        }
        // remove them from what's displayed
        displayedNetworks = displayedNetworks.filter({!toDelete.containsObject($0)})
        // remove them from the model
        for obj in toDelete {
            model.deleteNetwork(obj as! String)
            view.window!.documentEdited=true
        }
        // http://techone.xyz/using-nstableview-animations-with-bindings/
        NSAnimationContext.runAnimationGroup(
            {context in self.tableView.removeRowsAtIndexes(selectedRows,withAnimation: [.EffectFade, .SlideUp])},
            completionHandler:{}
        )
    }
    
    
    func windowWillClose(notification: NSNotification) {
        print("sending terminate")
        NSApp.terminate(self)
        print("sent terminate")
    }
}

