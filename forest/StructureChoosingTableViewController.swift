//
//  StructureChoosingTableViewController.swift
//  forest
//
//  Created by olderor on 23.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit

class StructureChoosingTableViewController : UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 2 {
            showInput()
            return
        }
        TaskManager.sturctureType = TaskStructureType(rawValue: indexPath.row)!
    }
    
    func showInput() {
        let alertController = UIAlertController(title: "Run console test", message: "Type number to insert number to the queue, type q to extract minimum from the queue. All commands must be separated by spaces. Example: '42 42 q q'", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Run", style: .default, handler: { (_) in
            if let field = alertController.textFields?[0] {
                let result = self.runTest(input: field.text!)
                
                let resultAlertController = UIAlertController(title: "Done", message: "Result: " + result, preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                resultAlertController.addAction(confirmAction)
                
                self.present(resultAlertController, animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addTextField(configurationHandler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func runTest(input: String) -> String {
        
        var result = ""
        let queue = BrodalPriorityQueue<Int>()
        let data = input.components(separatedBy: " ")
        var index = 0
        while index < data.count {
            if data[index] == "q" {
                let element = queue.extractMin()
                result += element == nil ? "nil " : "\(element!) "
            } else {
                if let element = Int(data[index]) {
                    queue.insert(element: element)
                } else {
                    return "Error format: " + input
                }
            }
            index += 1
        }
        return result
    }
}

