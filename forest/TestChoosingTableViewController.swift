//
//  TestChoosingTableController.swift
//  forest
//
//  Created by olderor on 23.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import UIKit

class TestChoosingTableViewController : UITableViewController {
    
    
    @IBAction func onBackNavigationItemTouchUpInside(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        TaskManager.taskType = TaskType(rawValue: indexPath.row)!
    }
    
}
