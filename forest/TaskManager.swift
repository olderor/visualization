//
//  TaskManager.swift
//  forest
//
//  Created by olderor on 22.12.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import Foundation


enum TaskStructureType : Int {
    case heap, queue
}

enum TaskType : Int {
    case custom, equal, increasing, decreasing, random
}

class TaskManager {
    static var sturctureType = TaskStructureType.queue
    static var taskType = TaskType.random
}
